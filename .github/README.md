# dotfiles

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

    After creating this file and populating it with anything you'd like, and rename the duplicate file `.dotfiles-local-settings.example` and clear out the values. This way, when you clone the repository to a new machine, you have a template to use to define your machine-specific settings.

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

7. Add the remote to the repository (change to the remote URL of your repo):

    ``` sh
    dotfiles remote add origin git@github.com:username/dotfiles.git
    ```

8. Add the `.gitignore` we created to the repository:

    ``` sh
    dotfiles add $HOME/.gitignore
    dotfiles commit -m "Adding .gitignore"
    ```

9.  Now you can easily add other files to be tracked from where they are supposed to be.

    For example, to add your `.bashrc` file:

    ``` sh
    dotfiles add $HOME/.bashrc
    dotfiles commit -m "Adding .bashrc"
    dotfiles push
    ```

    I like to add separate files for functions, aliases, etc. To add these files, I use a specific naming convention that makes it easy to add the files to the repository that looks like this: `.dotfiles-functions` and `.dotfiles-aliases`. Then, to add these files to source control, you can simply do this:

    ``` sh
    dotfiles add $HOME/.dotfiles-*
    dotfiles commit -m "Adding custom files"
    dotfiles push
    ```

## Install on a new system

1. Clone your dotfiles into a **bare** repository in your other computer's `$HOME` (change to the remote URL of your repo):

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
