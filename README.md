# mdmake

Simple pandoc wrapper utility that converts markdown format files to either:

- Beamer slides
- LaTeX pdf
- HTML documents
- Microsoft Word documents


## dependencies

- make
- rsync
- wget
- pandoc
- a LaTeX compiler


## install

Either put the repository content to your ```PATH``` or symlink ```mdmake``` file to it.
Make sure ```mdmake``` is executable.


## use

In a directory containing markdown documents (.md):
```Shell
$ mdmake [ slides | doc | html | word ]
```
