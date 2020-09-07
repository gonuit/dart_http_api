import {
  Drawer,
  Toolbar,
  List,
  ListSubheader,
  ListItemText,
  ListItem,
  ListItemIcon,
  makeStyles,
  Theme,
  createStyles,
} from "@material-ui/core";
import QuestionAnswer from "@material-ui/icons/QuestionAnswer";

import React from "react";
import {
  PatchIcon,
  GetIcon,
  PostIcon,
  PutIcon,
  HeadIcon,
  DeleteIcon,
} from "./Icons";
import { observer, inject } from "mobx-react";
import { RequestStore } from "../Stores/requestStore";

const DRAWER_WIDTH = 325;

const useStyles = makeStyles((theme: Theme) =>
  createStyles({
    drawer: {
      width: DRAWER_WIDTH,
      flexShrink: 0,
    },
    drawerPaper: {
      width: DRAWER_WIDTH,
    },
    drawerContainer: {
      overflow: "auto",
    },
    listSection: {
      backgroundColor: "#212124",
    },
  })
);

const getRequestIcon = (method: string) => {
  switch (method) {
    case "POST":
      return <PostIcon />;
    case "DELETE":
      return <DeleteIcon />;
    case "GET":
      return <GetIcon />;
    case "PUT":
      return <PutIcon />;
    case "HEAD":
      return <HeadIcon />;
    case "PATCH":
      return <PatchIcon />;
    default:
      return <QuestionAnswer />;
  }
};

export const RequestListDrawer: React.FC<{
  requestStore?: RequestStore;
}> = inject("requestStore")(
  observer(({ requestStore }) => {
    const classes = useStyles();

    return (
      <Drawer
        className={classes.drawer}
        variant="permanent"
        classes={{
          paper: classes.drawerPaper,
        }}
      >
        <Toolbar />
        <div className={classes.drawerContainer}>
          <List>
            <ListSubheader className={classes.listSection}>
              <ListItemText primary={"Requests"} />
            </ListSubheader>
            {requestStore!.data.map((requestData) => {
              return (
                <ListItem
                  onClick={() => {
                    requestStore?.select(requestData.id);
                  }}
                  style={{
                    backgroundColor:
                      requestData.id === requestStore?.selected?.id
                        ? "rgba(255,255,255,0.1)"
                        : "transparent",
                  }}
                  key={requestData.id}
                  button
                >
                  <ListItemIcon>
                    {getRequestIcon(requestData.request.method)}
                  </ListItemIcon>
                  <ListItemText primary={requestData.request.endpoint} />
                </ListItem>
              );
            })}
          </List>
        </div>
      </Drawer>
    );
  })
);
