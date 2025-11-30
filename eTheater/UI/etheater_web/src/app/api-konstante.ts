import { environment } from "../environments/environment";

export class ApiKonstante {
  static get baseUrl(): string {
    return `http://${environment.apiHost}:${environment.apiPort}`;
  }
}
