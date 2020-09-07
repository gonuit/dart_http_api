import React from "react";
import { Provider } from "mobx-react";
import { createStyles, Theme, makeStyles } from "@material-ui/core/styles";
import CssBaseline from "@material-ui/core/CssBaseline";

import { ThemeProvider, createMuiTheme } from "@material-ui/core";

import { RequestListDrawer } from "./Components/RequestListDrawer";
import { Editors } from "./Components/Editors";
import { CustomAppBar } from "./Components/CustomAppBar";
import { RequestStore } from "./Stores/requestStore";

const requestStore = new RequestStore();

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
    <Provider requestStore={requestStore}>
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
    </Provider>
  );
}
