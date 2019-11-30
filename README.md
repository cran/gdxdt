# gdxdt
Read/Write utilities for GAMS gdx files. Using R's [data.table](https://cran.r-project.org/package=data.table).

Requires GAMS `gdxrrw` library downloadable from [the GAMS wiki](https://support.gams.com/doku.php?id=gdxrrw:interfacing_gams_and_r).

## Install
```
require(devtools)
install_github("loisel/gdxdt")
```
`gdxdt` depends on the [`gdxrrw`](https://support.gams.com/doku.php?id=gdxrrw:interfacing_gams_and_r) library. To use this library you have
to set the gams library path via `igdx`.

## Usage

Read parameter, variable or set with symbol `name`:
```
dt <- readgdx("filename.gdx", "name")
```

Read upper bound field of variable, `field="l"` is the default:
```
dt <- readgdx("filename.gdx", "variable", field="up")
```

Write parameter:
```
dt <- data.table(
	col1=c("a", "b", "c"),
	col2=c("d", "e", "f"))
dt[, value:=runif(1), by="col1"]

writegdx.parameter("test.gdx", dt,
	name="test",
	valcol = "value",
	uelcols = c("col1", "col2"))
```

Write variable:
```
dt <- data.table(
	col1=c("a", "b", "c"),
	col2=c("d", "e", "f"))
dt[, value:=runif(1), by="col1"]

writegdx.variable("test.gdx", dt,
	name="test",
	valcol = "value",
	uelcols = c("col1", "col2"),
	field="l")
```
