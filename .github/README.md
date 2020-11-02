# dotfiles

Your computer's dotfiles are a key piece of your development environment. Many of us work on multiple computers throughout the day (e.g. work laptop, desktop at home, etc.) and managing to keep settings consistent across machines is a pain.

In this post, I'll walk you through one way to synchronize and back up your dotfiles utilizing a git repository.

## Starting from scratch

1. Create a bare repository in your `$HOME` directory:

    ``` sh
    mkdir $HOME/dotfiles
    git init --bare $HOME/dotfiles
    ```

2. Add a `.dotfiles-local-settings` file in your `$HOME` directory. This file will be the home for any alises, functions, values, etc. that you **do not** want to commit to the repository. I typically use this file for things like machine-specific values or aliases. For example:

    ``` sh
    # Create local settings file
    touch $HOME/.dotfiles-local-settings

    # This path may be different on my work computer
    echo "alias dev=\"cd /d/adam/Development\"" >> $HOME/.dotfiles-local-settings
    ```

    After creating this file and populating it with anything you'd like, duplicate it, and rename the duplicate file `.dotfiles-local-settings.example` and clear out the values. This way, when you clone the repository to a new machine, you have a template to use to define your machine-specific settings.

3. Add a `.gitignore` to your `$HOME` directory to ensure it will ignore the `dotfiles` folder where the bare repository lives, as well as your local settings file that you do not want in version control. You can also add any other files here you want to ensure do not get added:

    ``` sh
    echo -e "dotfiles/\n.dotfiles-local-settings" >> $HOME/.gitignore
    ```

4. Also add a `.gitignore` to this new repository to ensure it will ignore the folder where you'll eventually clone it on another machine (prevents weird recursion problems):

    ``` sh
    echo "dotfiles/" >> $HOME/dotfiles/.gitignore
    ```

5. Create an alias for running git commands in the `dotfiles` repository we just created (you only need to use one of the methods shown here):

    ```sh
    # Windows
    alias dotfiles='/cmd/git --git-dir=$HOME/dotfiles/ --work-tree=$HOME'

    # --------------------------------------------------------------------------- #

    # Mac (depends on location of git)
    alias dotfiles='/usr/bin/git --git-dir=$HOME/dotfiles/ --work-tree=$HOME'
    # or
    alias dotfiles='/usr/local/bin/git --git-dir=$HOME/dotfiles/ --work-tree=$HOME'
    ```

6. Next, configure the repository status to hide files we have not chosen to track (i.e. files we have not added), and to suppress the instructions on how to add ignored files:

    ``` sh
    # Hide files we have decided not to track
    dotfiles config --local status.showUntrackedFiles no

    # Suppress the instructions on how to add ignored files
    dotfiles config --local advice.addIgnoredFile false
    ```

7. Add the remote to the repository (change to the remote URL of your repo on GitHub, or wherever):

    ``` sh
    dotfiles remote add origin git@github.com:username/dotfiles.git
    ```

8. Add the `.gitignore` we created in our `$HOME` directory to the repository:

    ``` sh
    dotfiles add $HOME/.gitignore
    dotfiles commit -m "Adding .gitignore"
    ```

9. Now you can easily add other files to be tracked from where they are supposed to be.

    For example, to add your `.bashrc` file:

    ``` sh
    dotfiles add $HOME/.bashrc
    dotfiles commit -m "Adding .bashrc"
    dotfiles push
    ```

    I like to add separate files for functions, aliases, etc. To add these files, I use a specific naming convention that makes it easy to add the files to the repository that looks like this: `.dotfiles-functions` and `.dotfiles-aliases`.

    Then, to add these files to source control, you can simply do this:

    ``` sh
    dotfiles add $HOME/.dotfiles-*
    dotfiles commit -m "Adding custom files"
    dotfiles push
    ```

## Install on a new system

1. Clone your dotfiles into a **bare** repository in your other computer's `$HOME` (change to the remote URL of your repo on GitHub, or wherever):

    ``` sh
    git clone --bare git@github.com:username/dotfiles.git $HOME/dotfiles
    ```

2. Add the alias to the `.bashrc` or `.zshrc` on the new machine:

    ```sh
    # Windows
    alias dotfiles='/cmd/git --git-dir=$HOME/dotfiles/ --work-tree=$HOME'

    # --------------------------------------------------------------------------- #

    # Mac (depends on location of git)
    alias dotfiles='/usr/bin/git --git-dir=$HOME/dotfiles/ --work-tree=$HOME'
    # or
    alias dotfiles='/usr/local/bin/git --git-dir=$HOME/dotfiles/ --work-tree=$HOME'
    ```

3. Checkout the actual content from the bare repository to your `$HOME`:

    ``` sh
    dotfiles checkout
    ```

    You may receive an error message similar to the following:

    ``` sh
    error: The following untracked working tree files would be overwritten by checkout:
        .bashrc
        .bash_profile
    Please move or remove them before you can switch branches.
    Aborting
    ```

    This is because your `$HOME` folder may already contain some of the configuration files which would be overwritten by the checkout. To resolve, copy or back up the existing file(s) to another location if you care about them, otherwise, simply remove them.

    If you'd like to back up the current settings, here's a shortcut to move the matching files to a new folder:

    ``` sh
    mkdir -p $HOME/dotfiles-originals-backup && \
    dotfiles checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | \
    xargs -I{} mv {} $HOME/dotfiles-originals-backup/{}
    ```

    Then, re-run the checkout:

    ``` sh
    dotfiles checkout
    ```

4. Set the `showUntrackedFiles` flag to `no` for this local copy of your `dotfiles` repository:

    ``` sh
    dotfiles config --local status.showUntrackedFiles no
    ```

5. Duplicate the `.dotfiles-local-settings.example` file, and rename it to `.dotfiles-local-settings` (removing `.example`). Now, update the contents of the file to store the machine-specific values for this new computer. These settings will not be tracked in source control.

## Making updates

So you're up and running with your new way of managing dotfiles. Great! :tada: Now you want to make some updates, so let's walk through the update process.

### Editing a tracked file

Let's say you want to add a new function to your custom `.dotfiles-functions` file to search for files in your current directory.

Open the `.dotfiles-functions` file, and add the following lines:

``` sh
# Case insensitive file search, excluding node_modules and AppData directories
function ff() {
  find . -type d \( -iname node_modules -o -iname AppData \) -prune -false -o -type f -iname "*$1*"
}
```

With our new function in place, adding this change to our tracked version is simple. First, we'll add the file, write a commit message, and push it to our remote repository:

``` sh
# Remember to use your dotfiles alias!
dotfiles add -u
dotfiles commit -m "Adding find file function"
dotfiles push
```

Now that the function lives in the repository, we can easily pull down the changes on another computer:

``` sh
dotfiles pull
# Don't forget to source your .bashrc (or .zshrc, etc.) file to pull in the new function
source $HOME/.bashrc
```

### Adding a new file

To add a new file to be tracked with our dotfiles setup, simply create and edit the file, ensure it doesn't have any personal information that shouldn't live in source control, and add it to version control.

Remember, if the file contains any personal information or machine-specific information, it's better to place the information in your `.dotfiles-local-settings` file.

For this example, maybe we want to force Vim to use a specific theme. Create a new file `.vimrc`, and paste this content into the file:

``` sh
set background=dark
colorscheme solarized
let g:solarized_termtrans=1
```

Now, let's add the new file to our dotfiles repository:

``` sh
dotfiles add $HOME/.vimrc
dotfiles commit -m "Adding Vim config"
dotfiles push
```

Now that the new config file lives in our repository, we can easily pull down the new file to another computer:

``` sh
dotfiles pull
```
