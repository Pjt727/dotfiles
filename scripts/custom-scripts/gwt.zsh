#!/bin/zsh

# Git Worktree Manager with Jira Integration
# Requires: fzf, jq, curl, git
# Env vars for Jira: JIRA_USERNAME, JIRA_API_TOKEN, JIRA_CLOUD_ID, JIRA_SITE_URL
#
# Usage:
#   gwt                  - interactive action picker
#   gwt nav              - navigate to a worktree
#   gwt new              - create worktree (pick jira or manual)
#   gwt new jira         - create worktree from Jira ticket
#   gwt new manual       - create worktree with manual name
#   gwt new remote       - create worktree from a remote branch
#   gwt clean            - remove worktrees (merged ones pre-selected)

_gwt_get_repo_root() {
  git rev-parse --show-toplevel 2>/dev/null
}

_gwt_get_main_worktree() {
  git worktree list --porcelain | awk '/^worktree /{print $2; exit}'
}

_gwt_resolve_repo() {
  local repo_root
  repo_root=$(_gwt_get_repo_root)
  if [[ -z "$repo_root" ]]; then
    echo "Error: not inside a git repository" >&2
    return 1
  fi
  local main_root
  main_root=$(_gwt_get_main_worktree)
  [[ -n "$main_root" ]] && repo_root="$main_root"
  echo "$repo_root"
}

_gwt_default_branch() {
  local repo_root="$1"
  local default_branch
  default_branch=$(git -C "$repo_root" symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's|refs/remotes/origin/||')
  [[ -z "$default_branch" ]] && default_branch=$(git -C "$repo_root" config init.defaultBranch 2>/dev/null)
  [[ -z "$default_branch" ]] && default_branch="main"
  echo "$default_branch"
}

_gwt_fetch_jira_tickets() {
  if [[ -z "$JIRA_USERNAME" || -z "$JIRA_API_TOKEN" || -z "$JIRA_SITE_URL" ]]; then
    echo "Missing JIRA env vars (JIRA_USERNAME, JIRA_API_TOKEN, JIRA_SITE_URL)" >&2
    return 1
  fi

  local jql="assignee = currentUser() AND status NOT IN (Done, Closed) ORDER BY updated DESC"
  local url="${JIRA_SITE_URL}/rest/api/3/search/jql"
  local response

  response=$(curl -s -X POST \
    -u "${JIRA_USERNAME}:${JIRA_API_TOKEN}" \
    -H "Content-Type: application/json" \
    -d "$(jq -n --arg jql "$jql" '{jql: $jql, fields: ["summary", "status"], maxResults: 50}')" \
    "$url")

  if [[ $? -ne 0 ]] || echo "$response" | jq -e '.errorMessages // empty | length > 0' &>/dev/null; then
    echo "Failed to fetch Jira tickets" >&2
    echo "$response" | jq -r '.errorMessages[]?' >&2
    return 1
  fi

  echo "$response" | jq -r '.issues[] | "\(.key)\t\(.fields.summary)\t\(.fields.status.name)"'
}

_gwt_symlink_untracked() {
  local source_root="$1"
  local worktree_path="$2"

  local all_items=()
  for item in "$source_root"/*(N) "$source_root"/.*(N); do
    local basename="${item:t}"
    [[ "$basename" == "." || "$basename" == ".." || "$basename" == ".git" || "$basename" == ".worktrees" ]] && continue
    all_items+=("$basename")
  done

  local tracked_items=()
  tracked_items=("${(@f)$(git -C "$source_root" ls-files --cached | sed 's|/.*||' | sort -u)}")

  local linked=0
  local symlinked_items=()
  for item in "${all_items[@]}"; do
    local is_tracked=0
    for tracked in "${tracked_items[@]}"; do
      [[ "$item" == "$tracked" ]] && { is_tracked=1; break }
    done
    [[ $is_tracked -eq 1 ]] && continue

    local source_path="${source_root}/${item}"
    local target_path="${worktree_path}/${item}"
    [[ -e "$target_path" || -L "$target_path" ]] && continue

    ln -s "$source_path" "$target_path"
    symlinked_items+=("$item")
    ((linked++))
    echo "  symlinked: ${item}"
  done

  if [[ $linked -gt 0 ]]; then
    local wt_git_dir
    wt_git_dir=$(git -C "$worktree_path" rev-parse --git-dir 2>/dev/null)
    if [[ -n "$wt_git_dir" ]]; then
      mkdir -p "${wt_git_dir}/info"
      for item in "${symlinked_items[@]}"; do
        echo "$item" >> "${wt_git_dir}/info/exclude"
      done
    fi
  fi

  [[ $linked -eq 0 ]] && echo "  no untracked root items to symlink"
}

_gwt_slugify() {
  echo "$1" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//;s/-$//' | cut -c1-50
}

_gwt_create_worktree() {
  local repo_root="$1"
  local branch_name="$2"
  local worktree_parent="${repo_root}/.worktrees"
  mkdir -p "$worktree_parent"

  local dir_name="${branch_name//\//-}"
  local worktree_path="${worktree_parent}/${dir_name}"

  if [[ -d "$worktree_path" ]]; then
    echo "Worktree already exists, navigating to: ${worktree_path}"
    cd "$worktree_path"
    return 0
  fi

  local default_branch
  default_branch=$(_gwt_default_branch "$repo_root")

  local base_branch
  base_branch=$(git -C "$repo_root" branch -a --format='%(refname:short)' | \
    fzf --prompt="Base branch: " --height=~15 --no-info --query="$default_branch")
  [[ -z "$base_branch" ]] && { echo "Cancelled."; return 1 }

  echo ""
  echo "Creating worktree:"
  echo "  branch: ${branch_name}"
  echo "  path:   ${worktree_path}"
  echo "  base:   ${base_branch}"
  echo ""

  if git -C "$repo_root" show-ref --verify --quiet "refs/heads/${branch_name}"; then
    echo "(using existing branch)"
    if ! git -C "$repo_root" worktree add "$worktree_path" "$branch_name"; then
      echo "Error: failed to create worktree" >&2
      return 1
    fi
  else
    if ! git -C "$repo_root" worktree add -b "$branch_name" "$worktree_path" "$base_branch"; then
      echo "Error: failed to create worktree" >&2
      return 1
    fi
    git -C "$worktree_path" branch --unset-upstream 2>/dev/null
  fi

  echo ""
  echo "Creating symlinks for untracked root items..."
  _gwt_symlink_untracked "$repo_root" "$worktree_path"

  echo ""
  echo "Worktree ready at: ${worktree_path}"
  cd "$worktree_path"
}

_gwt_new_jira() {
  local repo_root="$1"

  echo "Fetching Jira tickets..."
  local tickets
  tickets=$(_gwt_fetch_jira_tickets)

  if [[ $? -ne 0 || -z "$tickets" ]]; then
    echo "No tickets found or fetch failed." >&2
    return 1
  fi

  local existing_wt_branches=()
  existing_wt_branches=("${(@f)$(git -C "$repo_root" worktree list --porcelain | awk '/^branch /{print $2}' | sed 's|refs/heads/||')}")

  local selected
  selected=$(echo "$tickets" | while IFS=$'\t' read -r key summary ticket_status; do
    local wt_marker=""
    for eb in "${existing_wt_branches[@]}"; do
      if [[ "$eb" == "${key}/"* ]]; then
        wt_marker=" [worktree]"
        break
      fi
    done
    printf "%s\t%-14s\t%s%s\n" "$key" "[$ticket_status]" "$summary" "$wt_marker"
  done | fzf --prompt="Select ticket: " --height=~20 --no-info \
             --preview="echo '${JIRA_SITE_URL}/browse/'{1}" \
             --preview-window=down,1)

  [[ -z "$selected" ]] && { echo "Cancelled."; return 1 }

  local ticket_key
  ticket_key=$(echo "$selected" | awk '{print $1}')

  local ticket_summary
  ticket_summary=$(echo "$tickets" | awk -F'\t' -v key="$ticket_key" '$1 == key {print $2}')

  local suggested_slug
  suggested_slug=$(_gwt_slugify "$ticket_summary")

  echo ""
  echo "Ticket: ${ticket_key} - ${ticket_summary}"
  echo "Suggested branch: ${ticket_key}/${suggested_slug}"
  echo ""

  echo "Branch description (enter for default, or type custom):"
  local description
  read -r "description?[${suggested_slug}]> "
  [[ -z "$description" ]] && description="$suggested_slug"

  _gwt_create_worktree "$repo_root" "${ticket_key}/${description}"
}

_gwt_new_manual() {
  local repo_root="$1"

  echo "Enter worktree branch name (e.g. AS-100/fix-user-screen):"
  local branch_name
  read -r "branch_name?> "
  [[ -z "$branch_name" ]] && { echo "Cancelled."; return 1 }

  _gwt_create_worktree "$repo_root" "$branch_name"
}

_gwt_new_remote() {
  local repo_root="$1"

  echo "Fetching remote branches..."
  git -C "$repo_root" fetch --all --prune 2>/dev/null

  local existing_branches=()
  existing_branches=("${(@f)$(git -C "$repo_root" worktree list --porcelain | awk '/^branch /{print $2}' | sed 's|refs/heads/||')}")

  local remote_branch
  remote_branch=$(git -C "$repo_root" branch -r --format='%(refname:short)' | \
    grep -v 'HEAD' | \
    while read -r rb; do
      local local_name="${rb#origin/}"
      local skip=0
      for eb in "${existing_branches[@]}"; do
        [[ "$local_name" == "$eb" ]] && { skip=1; break }
      done
      [[ $skip -eq 0 ]] && echo "$rb"
    done | \
    fzf --prompt="Select remote branch: " --height=~15 --no-info)

  [[ -z "$remote_branch" ]] && { echo "Cancelled."; return 1 }

  local local_name="${remote_branch#origin/}"
  local dir_name="${local_name//\//-}"
  local worktree_parent="${repo_root}/.worktrees"
  mkdir -p "$worktree_parent"
  local worktree_path="${worktree_parent}/${dir_name}"

  if [[ -d "$worktree_path" ]]; then
    echo "Worktree already exists, navigating to: ${worktree_path}"
    cd "$worktree_path"
    return 0
  fi

  echo ""
  echo "Creating worktree from remote:"
  echo "  remote:  ${remote_branch}"
  echo "  branch:  ${local_name}"
  echo "  path:    ${worktree_path}"
  echo ""

  if ! git -C "$repo_root" worktree add --track -b "$local_name" "$worktree_path" "$remote_branch"; then
    echo "Error: failed to create worktree" >&2
    return 1
  fi

  echo ""
  echo "Creating symlinks for untracked root items..."
  _gwt_symlink_untracked "$repo_root" "$worktree_path"

  echo ""
  echo "Worktree ready at: ${worktree_path}"
  cd "$worktree_path"
}

_gwt_nav() {
  local repo_root="$1"

  local selected
  selected=$(git -C "$repo_root" worktree list | \
    fzf --prompt="Select worktree: " --height=~15 --no-info | \
    awk '{print $1}')

  [[ -z "$selected" ]] && { echo "Cancelled."; return 1 }

  echo "Navigating to: ${selected}"
  cd "$selected"
}

_gwt_clean() {
  local repo_root="$1"
  local main_root
  main_root=$(_gwt_get_main_worktree)

  # Get default branch for merge checking
  local default_branch
  default_branch=$(_gwt_default_branch "$repo_root")

  git -C "$repo_root" fetch --all --prune 2>/dev/null

  # Build worktree list with status annotations
  local entries=()
  local preselect_indices=()
  local idx=0

  while IFS= read -r line; do
    local wt_path wt_branch
    wt_path=$(echo "$line" | awk '{print $1}')
    wt_branch=$(echo "$line" | sed -n 's/.*\[\(.*\)\].*/\1/p')

    # Skip the main worktree
    [[ "$wt_path" == "$main_root" ]] && continue

    # Check status
    local has_changes=false
    local is_pushed=false
    local is_merged=false
    local markers=""

    # Uncommitted changes (dirty working tree or staged)
    if [[ -n "$(git -C "$wt_path" status --porcelain 2>/dev/null)" ]]; then
      has_changes=true
      markers+=" [dirty]"
    fi

    # Check if branch is pushed to remote
    if git -C "$repo_root" rev-parse --verify "refs/remotes/origin/${wt_branch}" &>/dev/null; then
      local local_rev remote_rev
      local_rev=$(git -C "$repo_root" rev-parse "refs/heads/${wt_branch}" 2>/dev/null)
      remote_rev=$(git -C "$repo_root" rev-parse "refs/remotes/origin/${wt_branch}" 2>/dev/null)
      if [[ "$local_rev" == "$remote_rev" ]]; then
        is_pushed=true
      else
        markers+=" [unpushed]"
      fi
    else
      markers+=" [no remote]"
    fi

    # Check if merged into default branch on remote
    if git -C "$repo_root" branch -r --merged "origin/${default_branch}" 2>/dev/null | grep -q "origin/${wt_branch}$"; then
      is_merged=true
      markers+=" [merged]"
    fi

    local display="${wt_path}\t${wt_branch}${markers}"
    entries+=("$display")

    # Pre-select merged branches
    if $is_merged; then
      preselect_indices+=($idx)
    fi

    ((idx++))
  done < <(git -C "$repo_root" worktree list)

  if [[ ${#entries[@]} -eq 0 ]]; then
    echo "No worktrees to clean (only main worktree exists)."
    return 0
  fi

  # Build fzf input, marking pre-selected lines
  local fzf_input=""
  for i in {1..${#entries[@]}}; do
    fzf_input+="${entries[$i]}\n"
  done

  # Build --select args for pre-selecting merged worktrees
  local select_args=()
  for i in "${preselect_indices[@]}"; do
    local pattern
    pattern=$(echo "${entries[$((i+1))]}" | sed 's/[][\\.^$*+?(){}|]/\\&/g')
    select_args+=(--select "$pattern")
  done

  echo "Select worktrees to remove (TAB to toggle, ENTER to confirm):"
  echo ""

  local selected
  selected=$(printf "$fzf_input" | \
    fzf --multi --prompt="gwt clean> " --height=~20 --no-info \
        --header="[dirty]=uncommitted changes  [unpushed]=not on remote  [merged]=merged into ${default_branch}" \
        "${select_args[@]}")

  [[ -z "$selected" ]] && { echo "Cancelled."; return 1 }

  # If currently in a worktree that will be removed, go to main first
  local current_dir
  current_dir=$(pwd -P)

  local removed=0
  local skipped=0

  while IFS= read -r line; do
    local wt_path wt_branch
    wt_path=$(echo "$line" | awk -F'\t' '{print $1}')
    wt_branch=$(echo "$line" | awk -F'\t' '{print $2}' | awk '{print $1}')

    # Check if confirmation needed
    local needs_confirm=false
    if echo "$line" | grep -q '\[dirty\]'; then
      needs_confirm=true
    fi

    if $needs_confirm; then
      echo ""
      echo "WARNING: ${wt_branch} has uncommitted changes!"
      echo "  path: ${wt_path}"
      echo -n "  Remove anyway? [y/N] "
      local confirm
      read -r "confirm?" </dev/tty
      if [[ "$confirm" != [yY] ]]; then
        echo "  Skipped."
        ((skipped++))
        continue
      fi
    fi

    # Navigate away if we're inside this worktree
    if [[ "$current_dir" == "$wt_path"* ]]; then
      cd "$main_root"
    fi

    echo "Removing: ${wt_branch} (${wt_path})"
    git -C "$repo_root" worktree remove --force "$wt_path" 2>/dev/null
    if [[ $? -eq 0 ]]; then
      # Delete the branch too if it was merged
      if echo "$line" | grep -q '\[merged\]'; then
        git -C "$repo_root" branch -d "$wt_branch" 2>/dev/null
      fi
      ((removed++))
    else
      echo "  Failed to remove worktree at ${wt_path}" >&2
    fi
  done <<< "$selected"

  echo ""
  echo "Removed ${removed} worktree(s), skipped ${skipped}."
}

gwt() {
  local repo_root
  repo_root=$(_gwt_resolve_repo) || return 1

  local action="$1"
  local sub="$2"

  # No args — interactive picker
  if [[ -z "$action" ]]; then
    local pick
    pick=$(printf "%-12s %s\n" \
      "nav" "Navigate to an existing worktree" \
      "new jira" "Create worktree from a Jira ticket" \
      "new manual" "Create worktree with a manual name" \
      "new remote" "Create worktree from a remote branch" \
      "clean" "Remove worktrees (pre-selects merged)" | \
      fzf --prompt="gwt> " --height=~6 --no-info)
    [[ -z "$pick" ]] && { echo "Cancelled."; return 1 }

    action=$(echo "$pick" | awk '{print $1}')
    if [[ "$action" == "new" ]]; then
      sub=$(echo "$pick" | awk '{print $2}')
    fi
  fi

  case "$action" in
    nav)
      _gwt_nav "$repo_root"
      ;;
    new)
      # Sub-action for new
      if [[ -z "$sub" ]]; then
        local subpick
        subpick=$(printf "%-8s %s\n" \
          "jira" "Create from a Jira ticket" \
          "manual" "Enter branch name manually" \
          "remote" "Checkout a remote branch" | \
          fzf --prompt="gwt new> " --height=~5 --no-info)
        [[ -z "$subpick" ]] && { echo "Cancelled."; return 1 }
        sub=$(echo "$subpick" | awk '{print $1}')
      fi

      case "$sub" in
        jira)   _gwt_new_jira "$repo_root" ;;
        manual) _gwt_new_manual "$repo_root" ;;
        remote) _gwt_new_remote "$repo_root" ;;
        *)      echo "Unknown: gwt new $sub (use: jira, manual, remote)" >&2; return 1 ;;
      esac
      ;;
    clean)
      _gwt_clean "$repo_root"
      ;;
    *)
      echo "Unknown: gwt $action (use: nav, new, clean)" >&2
      return 1
      ;;
  esac
}
