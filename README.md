# RestorationOfErathia

A tool to assist with restoring deleted files, made for Linux OS


## Usage
####Usecase
Imagine having to restore deleted files from hdd (or SSD or USB flash drive) using tools like `photorec`.

At the end of the restoration process you end up having multiple folders with all sorts of files in them.

It looks messy, filenames differ from original ones, there are multiple duplicate files and old folder structure is gone.

The tool is aimed at helping out the user.

####Initial configuration
There are several things that need to be configured before running the script.

Module constant `@path` corresponds to the path of the folder where restored data is (in form of `recup.1.dir`, `recup.2.dir`, ... folders).
Change it to relevant path to restored data on your pc.

Module constant `@formats` corresponds to different formats that are highly relevant for you personally in restoration process.
For example, you might not care about images, executable files, dlls or code, just the documents, spreadsheets, presentations and pdfs.
Please add/remove formats to this module constant so that it corresponds better to your needs.

####Main usage
Run in terminal `iex -S mix` followed by
```
r = RestorationOfErathia
r.run()
```

This function will move all the files of pre-specified format to separate folders,
deduplicate files, move all the other files to
common folder `merged` and will delete any empty folders. 

####Extras
Now imagine that you have an old backup which contains some pdf files from a flashdrive and you'd like 
to remove those existing files from recovered ones. There is a function to facilitate that:

```
r = RestorationOfErathia
r.deduplicate_between_folders(folder_path_uniq, folder_path_duplicate)
```
in here, the folder with the backup pdfs will be `folder_path_uniq` and folder with the restored pdfs will
be `folder_path_duplicate`. And the function will remove all the files already existing in `folder_path_uniq` from
`folder_path_duplicate` folder.

Now imagine that you have duplicates inside some other folder, not related to restoration process, but there are
so many files in that folder that you can't be bothered to deduplicate them manually. No problem, as
```
r = RestorationOfErathia
r.deduplicate_folder(folder_path)
```
will remove all the duplicate files from a folder.

For more detailed usage examples, see Documentation

## Installation

The package can be installed by adding `restoration_of_erathia` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:restoration_of_erathia, "~> 0.1.0"}
  ]
end
```

## Documentation

The docs can be found at [https://hexdocs.pm/restoration_of_erathia](https://hexdocs.pm/restoration_of_erathia).

