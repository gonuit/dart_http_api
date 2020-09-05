import {
  AppBar,
  Toolbar,
  Typography,
  makeStyles,
  createStyles,
  Theme,
} from "@material-ui/core";
import React from "react";

const useStyles = makeStyles((theme: Theme) =>
  createStyles({
    appBar: {
      zIndex: theme.zIndex.drawer + 1,
    },
  })
);

export const CustomAppBar: React.FC = () => {
  const classes = useStyles();

  return (
    <AppBar position="fixed" className={classes.appBar}>
      <Toolbar>
        <Typography variant="h6" noWrap>
          http_api devtools
        </Typography>
      </Toolbar>
    </AppBar>
  );
};
