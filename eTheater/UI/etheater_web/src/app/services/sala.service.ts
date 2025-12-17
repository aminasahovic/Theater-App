import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { ApiKonstante } from '../api-konstante';
import { AuthService } from './auth.service';

@Injectable({ providedIn: 'root' })
export class SalaService {
  private baseUrl = `${ApiKonstante.baseUrl}/Sala`;

  constructor(private http: HttpClient, private auth: AuthService) {}

  private authHeader() {
    const token = btoa(`${this.auth.username}:${this.auth.password}`);
    return { headers: { "Authorization": `Basic ${token}` } };
  }

  getSale(): Observable<any> {
    return this.http.get<any>(this.baseUrl, this.authHeader());
  }
}
