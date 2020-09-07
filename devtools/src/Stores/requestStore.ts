import { observable, action, computed } from "mobx";
import io from "socket.io-client";

interface ApiResponse {
  id: string;
  body: string;
  bodyBytes: Array<number>;
  headers: Record<string, string>;
  ok: boolean;
  redirect: boolean;
}

interface ApiRequest {
  id: string;
  method: string;
  endpoint: string;
  body: string;
  url: string;
  apiUrl: string;
  queryParameters: Record<string, string>;
}

interface ApiData {
  id: string;
  request: ApiRequest;
  response?: ApiResponse;
}

export class RequestStore {
  @observable data: Array<ApiData> = [];

  @computed get selected(): ApiData | undefined {
    if (this.selectedId === undefined) return undefined;
    return this.data.find((data) => data.id === this.selectedId);
  }

  @observable selectedId: undefined | string = undefined;

  @action select = (id: string) => {
    this.selectedId = id;
  };

  constructor() {
    const socket = io("http://localhost:8080");
    socket.on("connect", () => {});

    socket.on("request", (requestString: any) => {
      const request = JSON.parse(requestString);
      const requestData = { request, id: request.id };
      this.data.unshift(requestData);
      if (this.data.length === 1 && this.selectedId === undefined) {
        this.selectedId = request.id;
      }
    });

    socket.on("response", (data: any) => {
      const response = JSON.parse(data);

      const requestData = this.data.find((data) => data.id === response.id);

      if (requestData && !requestData.response) {
        requestData.response = response;
      }
    });

    socket.on("disconnect", () => {});
  }
}
