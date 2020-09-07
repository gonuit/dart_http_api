import { Box, Toolbar, Typography, Divider } from "@material-ui/core";
import React from "react";
import Editor from "@monaco-editor/react";
import { RequestStore } from "../Stores/requestStore";
import { observer, inject } from "mobx-react";

export const Editors: React.FC<{
  requestStore?: RequestStore;
}> = inject("requestStore")(
  observer(({ requestStore }) => {
    return (
      <Box height="100%" display="flex" flexDirection="column">
        <Box>
          <Toolbar />
        </Box>
        <Box
          position="relative"
          display="flex"
          width="100%"
          flexGrow={1}
          flexDirection="column"
        >
          <Box
            display="flex"
            alignItems="center"
            justifyContent="flex-start"
            height="25px"
            paddingLeft={1}
            style={{ backgroundColor: "#3c3c3f" }}
          >
            <Typography variant="body2" gutterBottom={false}>
              ApiRequest
            </Typography>
          </Box>
          <Box
            flex={1}
            position="relative"
            display="flex"
            flexGrow={1}
            flexDirection="column"
          >
            <Editor
              options={{
                readOnly: true,
                minimap: {
                  enabled: false,
                },
              }}
              language="json"
              theme="dark"
              value={JSON.stringify(
                requestStore?.selected?.request,
                undefined,
                2
              )}
            />
          </Box>
          <Divider />
          <Box
            display="flex"
            alignItems="center"
            justifyContent="flex-start"
            height="25px"
            paddingLeft={1}
            style={{ backgroundColor: "#3c3c3f" }}
          >
            <Typography variant="body2" gutterBottom={false}>
              ApiResponse
            </Typography>
          </Box>
          <Box
            flex={1}
            position="relative"
            display="flex"
            flexGrow={1}
            flexDirection="column"
          >
            <Editor
              options={{
                readOnly: true,
                minimap: {
                  enabled: false,
                },
              }}
              language="json"
              theme="dark"
              value={JSON.stringify(
                requestStore?.selected?.response,
                undefined,
                2
              )}
            />
          </Box>
        </Box>
      </Box>
    );
  })
);
