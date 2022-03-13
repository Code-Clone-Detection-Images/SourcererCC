# SourcererCC

Run [SourcererCC](https://github.com/Mondego/SourcererCC) on a supplied folder.

**Build** using the [`makefile`](makefile).
**Run** using the [run-script](run.sh) script, supply it with the project folder. This project is in need of docker-compose, as SourcererCC requires a for the database.

> As only the `pwd` (current working directory) will be mounted automatically, you can not specify files/folders located in upper levels.

Example:

```bash
make
./run.sh java-small
```

After running, the program will output the results of the sql database.

> As the enumeration of SourcererCC depends on the order it visits projects,
> the [run-script](run.sh) allows another argument, a file that contains the list of projects in visiting-order (see [`projects.txt`](test_source/projects.txt) as an example it is used to reproduce the results of the SourcererCC-paper).
>