import { observable } from "mobx";
import io from "socket.io-client";

export class RequestData {}

export class RequestStore {
  @observable requests: Array<RequestData> = [];

  constructor() {
    const socket = io("http://localhost:8080");
    socket.on("connect", () => {});
    socket.on("new_request", (data: any) => {
      console.log("NEW REQUEST");

      this.requests.push(data);
    });
    socket.on("disconnect", () => {});
  }
}
