## Build this
1. Get & install stack: `wget -qO- https://get.haskellstack.org/ | s`
2. Run `../test.sh` and `.././benchmark.py` as usual.

This uses stack LTS 18.18 / GHC 8.10.4, but with text-2.0.1 so we can
use the clutter package.

## Compare the Haskell versions

Run `./run.sh` to time all the versions. If you have nix installed,
it'll use `hyperfine` to get more accurate timings.

| Command               | Mean [s]      | Min [s] | Max [s] |
| :---                  | ---:          | ---:    | ---:    |
| BufwiseClutter        | 1.551 ± 0.034 | 1.481   | 1.594   |
| BufwiseVHBS           | 1.726 ± 0.071 | 1.657   | 1.855   |
| LinewiseClutter       | 1.867 ± 0.033 | 1.848   | 1.996   |
| LazyVH                | 2.148 ± 0.056 | 2.104   | 2.257   |
| StreamlyVH            | 2.273 ± 0.048 | 2.189   | 2.330   |
| LinewiseVH            | 2.411 ± 0.031 | 2.380   | 2.484   |
| LazyHMRef             | 2.724 ± 0.035 | 2.683   | 2.772   |
| StreamlyHMRef         | 2.559 ± 0.039 | 2.515   | 2.657   |
| StreamlyThreadedHMRef | 2.955 ± 0.126 | 2.859   | 3.158   |
| LazyHMBS              | 5.945 ± 0.115 | 5.822   | 6.232   |
| LazyMap               | 6.058 ± 0.075 | 5.991   | 6.217   |
| StreamingHMBS         | 6.765 ± 0.212 | 6.564   | 7.204   |
