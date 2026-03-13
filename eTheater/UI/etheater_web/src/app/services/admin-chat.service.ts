import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { ApiKonstante } from '../api-konstante';
import { AuthService } from './auth.service';
import { lastValueFrom } from 'rxjs';

export interface ChatMessage {
  text: string;
  isAdmin: boolean;
  time: Date;
}

@Injectable({ providedIn: 'root' })
export class AdminChatService {
  private url = `${ApiKonstante.baseUrl}/api/admin-chat`;

  constructor(private http: HttpClient, private auth: AuthService) {}

  private authHeader() {
    if (!this.auth.username || !this.auth.password) return {};
    const token = btoa(`${this.auth.username}:${this.auth.password}`);
    return { headers: { Authorization: `Basic ${token}` } };
  }

  async sendMessage(message: string, previousResponse: string): Promise<string> {
    const body = { message, previousResponse };
    const response = await lastValueFrom(
      this.http.post<{ reply: string }>(this.url, body, this.authHeader())
    );
    return response.reply;
  }
}
