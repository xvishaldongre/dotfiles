#!/usr/bin/env bash

WORKTREE_ROOT="$HOME/xwork"

# Helper: Get current repo name from cwd
get_repo_name() {
    basename "$(git rev-parse --show-toplevel 2>/dev/null)"
}

# gwa: git worktree add
# usage: gwa <new_branch> [source_branch]
gwa() {
    local new_branch=$1
    local source_branch=${2:-}
    if [[ -z "$new_branch" ]]; then
        echo "Usage: gwa <new_branch> [source_branch]"
        return 1
    fi

    # Find source branch: default main or master
    if [[ -z "$source_branch" ]]; then
        if git show-ref --verify --quiet refs/heads/main; then
            source_branch="main"
        elif git show-ref --verify --quiet refs/heads/master; then
            source_branch="master"
        else
            echo "No source branch specified and neither 'main' nor 'master' found."
            return 1
        fi
    fi

    local repo
    repo=$(get_repo_name)
    if [[ -z "$repo" ]]; then
        echo "Not inside a git repo."
        return 1
    fi

    # Sanitize new_branch for folder name (replace slashes with dashes)
    local safe_branch=${new_branch//\//-}

    # Folder name with format: wt:<repo_name>:<new_branch>
    local worktree_folder="$WORKTREE_ROOT/wt:${repo}:${safe_branch}"

    mkdir -p "$WORKTREE_ROOT"

    echo "Adding worktree at $worktree_folder from $source_branch branch, new branch $new_branch..."

    git worktree add -b "$new_branch" "$worktree_folder" "$source_branch" || return 1

    # Add to zoxide database for quick access
    if command -v zoxide >/dev/null 2>&1; then
        echo "Adding worktree folder to zoxide database..."
        zoxide add "$worktree_folder"
    fi

    echo "Worktree created: $worktree_folder"
}

# gwp: git worktree prune
gwp() {
    git worktree prune
}

# gwd: git worktree delete
# usage: gwd <worktree_path_or_branch>
gwd() {
    local target=$1
    if [[ -z "$target" ]]; then
        echo "Usage: gwd <worktree_path_or_branch>"
        return 1
    fi

    if [[ -d "$target" ]]; then
        echo "Removing worktree by path: $target"
        git worktree remove "$target"
        echo "Deleting folder $target"
        rm -rf "$target"
        return $?
    fi

    local worktree_path
    worktree_path=$(git worktree list --porcelain |
        awk -v branch="refs/heads/$target" '
        $1 == "worktree" { wt = $2 }
        $1 == "branch" && $2 == branch { print wt }
      ')

    if [[ -n "$worktree_path" ]]; then
        echo "Removing worktree for branch $target at path $worktree_path"
        git worktree remove "$worktree_path"
        echo "Deleting folder $worktree_path"
        rm -rf "$worktree_path"
    else
        echo "No worktree found for branch or path: $target"
        return 1
    fi
}
