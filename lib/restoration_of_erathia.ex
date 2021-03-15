defmodule RestorationOfErathia do
  @moduledoc """
  Documentation for `RestorationOfErathia`.
  The module is designed to assist with restoration of deleted files from hdd.

  It is assumed that a tool similar to photorec is used to restore the deleted files.
  The documentation for using photorec can be found here: https://www.cgsecurity.org/testdisk.pdf

  Two things need to be configured: folder path to folder where restored data is and
  formats that should be separated out of the rest of the restored data.
  """

  @path "/home/andriy/Code/IdeaProjects/restoration_of_erathia/tmp"
  @formats [
    "txt",
    "jpg",
    "pdf",
    "exe",
    "docx",
    "xlsx",
    "xls",
    "doc",
    "pptx",
    "ppt",
    "ods",
    "odt",
    "tif",
    "png",
    "dat"
  ]

  defp extract_all_files_having(format) do
    File.cd(@path)
    {:ok, dirnames} = File.ls()

    dirnames
    |> Enum.map(fn dirname -> {File.dir?("#{@path}/#{dirname}"), "#{@path}/#{dirname}"} end)
    |> Enum.map(fn {dir?, dirname} ->
      if dir? do
        extract_dir(dirname, format)
      end
    end)
  end


  defp extract_dir(dirname, format) do
    Path.wildcard("#{dirname}/*.#{format}")
    |> Enum.map(fn filepath -> move_to_dir(filepath, format) end)
  end

  @doc ~S"""
  Finds all the files that have the specified extension format in a directory and moves them to a directory
  named after the extension format. Moves all files with unspecified extensions to a merged folder.
  Test requires specific path setting in module constants.

  ## Examples

      iex> r = RestorationOfErathia
      iex> {:ok, wd} = File.cwd()
      iex> File.mkdir("#{wd}/tmp")
      iex> File.touch("#{wd}/tmp/test.txt")
      iex> r.move_to_dir("#{wd}/tmp/test.txt", "txt")
      iex> File.rm("#{wd}/tmp/txt/test.txt")
      iex> File.rmdir("#{wd}/tmp/txt")
      iex> File.rmdir("#{wd}/tmp")
      :ok


  """
  def move_to_dir(filepath, format) do
    folder =
      case format do
        "*" -> "#{@path}/merged/"
        _ -> "#{@path}/#{format}/"
      end

    if File.exists?(folder) do
      File.rename!(filepath, "#{folder}#{Path.basename(filepath)}")
    else
      File.mkdir!(folder)
      File.rename!(filepath, "#{folder}#{Path.basename(filepath)}")
    end
  end

  defp merge_all(formats) do
    File.cd(@path)
    {:ok, dirnames} = File.ls()

    dirnames
    |> Enum.reject(fn dirname -> Path.basename(dirname) in formats end)
    |> Enum.map(fn dirname -> extract_dir(dirname, "*") end)
  end

  defp compute_hash(file_path) do
    hash =
      File.stream!(file_path, [], 2_048)
      |> Enum.reduce(:crypto.hash_init(:sha256), &:crypto.hash_update(&2, &1))
      |> :crypto.hash_final()
      |> Base.encode16()
      |> String.downcase()

    {file_path, hash}
  end

  @doc ~S"""
  Given 2 folder paths, unique and duplicate, finds all files in duplicate folder that already exist in unique folder,
  based on hashes. Removes all the files with matching hashes from duplicate folder.

  ## Examples
      iex> r = RestorationOfErathia
      iex> {:ok, wd} = File.cwd()
      iex> File.mkdir("#{wd}/tmp")
      iex> File.touch("#{wd}/tmp/test.txt")
      iex> File.mkdir("#{wd}/tmp2")
      iex> File.cp("#{wd}/tmp/test.txt", "#{wd}/tmp2/test.txt")
      iex> r.deduplicate_between_folders("#{wd}/tmp", "#{wd}/tmp2")
      iex> File.rm("#{wd}/tmp/test.txt")
      iex> File.rmdir("#{wd}/tmp")
      iex> File.rmdir("#{wd}/tmp2")
      :ok
  """

  def deduplicate_between_folders(unique_folder_path, duplicate_folder_path) do
    uniq_hashes =
      find_uniques_with_hashes_in_folder(unique_folder_path)
      |> Enum.map(fn {_fname, hash} -> hash end)

    find_uniques_with_hashes_in_folder(duplicate_folder_path)
    |> Enum.filter(fn {_fname, hash} -> hash in uniq_hashes end)
    |> Enum.map(fn {fname, _hash} -> fname end)
    |> Enum.map(fn file_name -> File.rm!(file_name) end)
  end

  defp ls_r(path \\ ".") do
    cond do
      File.regular?(path) ->
        [path]

      File.dir?(path) ->
        File.ls!(path)
        |> Enum.map(&Path.join(path, &1))
        |> Enum.map(&ls_r/1)
        |> Enum.concat()

      true ->
        []
    end
  end

  defp find_uniques_with_hashes_in_folder(folder_path) do
    ls_r(folder_path)
    |> Enum.map(fn file_path -> compute_hash(file_path) end)
    |> Enum.uniq_by(fn {_, hash} -> hash end)
  end

  defp remove_duplicates_from_folder(folder_path, uniques_list) do
    Path.wildcard("#{folder_path}/*.*")
    |> Enum.reject(fn file_name -> file_name in uniques_list end)
    |> Enum.map(fn file_name -> File.rm!(file_name) end)
  end

  @doc ~S"""
  Removes duplicated files inside a folder (using file hash)

  ## Examples

      iex> r = RestorationOfErathia
      iex> {:ok, wd} = File.cwd()
      iex> File.mkdir("#{wd}/tmp")
      iex> File.touch("#{wd}/tmp/test.txt")
      iex> File.cp("#{wd}/tmp/test.txt", "#{wd}/tmp/test2.txt")
      iex> r.deduplicate_folder("#{wd}/tmp")
      iex> File.rm("#{wd}/tmp/test2.txt")
      iex> File.rmdir("#{wd}/tmp")
      :ok

  """


  def deduplicate_folder(folder_path) do
    uniques =
      find_uniques_with_hashes_in_folder(folder_path)
      |> Enum.map(fn {fname, _hash} -> fname end)

    remove_duplicates_from_folder(folder_path, uniques)
  end

  @doc """
  Removes duplicated files from all the folders present in a given path
  """

  def deduplicate_all_folders(path) do
    File.cd(path)
    {:ok, dirnames} = File.ls()

    dirnames
    |> Enum.map(fn dirname -> deduplicate_folder(dirname) end)
  end

  @doc ~S"""
  Removes all empty folders from a given path

  ## Examples

      iex> r = RestorationOfErathia
      iex> {:ok, wd} = File.cwd()
      iex> File.mkdir("#{wd}/tmp")
      iex> File.mkdir("#{wd}/tmp2")
      iex> r.remove_empty_folders("#{wd}")

  """

  def remove_empty_folders(path) do
    {:ok, files_and_folders} = File.ls(path)

    files_and_folders
    |> Enum.map(fn endfile_or_folder ->
      if File.dir?("#{path}/#{endfile_or_folder}") do
        File.rmdir("#{path}/#{endfile_or_folder}")
      end
    end)
  end

  @doc """
  Runs the entire helper pipeline:
  * Separates data according to folders according to formats.
  * Merges all unset formats to a single folder.
  * Deduplicates files within the folders.
  * Removes empty folders

  """

  def run() do
    @formats
    |> Enum.map(fn format -> extract_all_files_having(format) end)

    merge_all(@formats)

    deduplicate_all_folders(@path)

    remove_empty_folders(@path)
  end
end
