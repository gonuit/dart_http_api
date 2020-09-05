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
import React from "react";
import {
  PatchIcon,
  GetIcon,
  PostIcon,
  PutIcon,
  HeadIcon,
  DeleteIcon,
} from "./Icons";

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

// TODO: REMOVE MOCK
const icons = [
  <PatchIcon />,
  <DeleteIcon />,
  <GetIcon />,
  <PutIcon />,
  <HeadIcon />,
  <PostIcon />,
];

export const RequestListDrawer: React.FC = () => {
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
          <ListItem button>
            <ListItemIcon>
              <PatchIcon />
            </ListItemIcon>
            <ListItemText primary={"Patch"} />
          </ListItem>
          <ListItem button>
            <ListItemIcon>
              <GetIcon />
            </ListItemIcon>
            <ListItemText primary={"Get"} />
          </ListItem>
          <ListItem button>
            <ListItemIcon>
              <PostIcon />
            </ListItemIcon>
            <ListItemText primary={"Post"} />
          </ListItem>
          <ListItem button>
            <ListItemIcon>
              <PutIcon />
            </ListItemIcon>
            <ListItemText primary={"Put"} />
          </ListItem>
          <ListItem button>
            <ListItemIcon>
              <HeadIcon />
            </ListItemIcon>
            <ListItemText primary={"Head"} />
          </ListItem>
          <ListItem button>
            <ListItemIcon>
              <DeleteIcon />
            </ListItemIcon>
            <ListItemText primary={"Delete"} />
          </ListItem>
          {new Array(100).fill(1).map((_, index) => {
            return (
              <ListItem button>
                <ListItemIcon>{icons[index % 6]}</ListItemIcon>
                <ListItemText primary={`/photos/${index + 342}`} />
              </ListItem>
            );
          })}
        </List>
      </div>
    </Drawer>
  );
};
