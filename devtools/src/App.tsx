import React from "react";
import { createStyles, Theme, makeStyles } from "@material-ui/core/styles";
import CssBaseline from "@material-ui/core/CssBaseline";

import { ThemeProvider, createMuiTheme } from "@material-ui/core";

import { RequestListDrawer } from "./Components/RequestListDrawer";
import { Editors } from "./Components/Editors";
import { CustomAppBar } from "./Components/CustomAppBar";

const useStyles = makeStyles((theme: Theme) =>
  createStyles({
    root: {
      display: "flex",
    },
    content: {
      height: "100vh",
      flexGrow: 1,
      flex: 1,
    },
  })
);

export default function ClippedDrawer() {
  const classes = useStyles();

  const darkTheme = createMuiTheme({
    palette: {
      background: {
        default: "#212124",
        paper: "#212124",
      },
      primary: { main: "#313133" },
      type: "dark",
    },
  });

  return (
    <ThemeProvider theme={darkTheme}>
      <div className={classes.root}>
        <CssBaseline />
        <CustomAppBar />
        <RequestListDrawer />
        <main className={classes.content}>
          <Editors />
        </main>
      </div>
    </ThemeProvider>
  );
}
