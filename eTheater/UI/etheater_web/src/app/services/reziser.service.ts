import { Injectable } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable, map } from 'rxjs';
import { ApiKonstante } from '../api-konstante';
import { AuthService } from './auth.service';

export interface Reziser { id: number; ime: string; prezime: string; }
export interface InsertReziser { ime: string; prezime: string; }

@Injectable({ providedIn: 'root' })
export class ReziserService {
  private baseUrl = `${ApiKonstante.baseUrl}/Reziser`;

  constructor(private http: HttpClient, private auth: AuthService) {}

  private authHeader() {
    if (!this.auth.username || !this.auth.password) return {};
    const token = btoa(`${this.auth.username}:${this.auth.password}`);
    return { headers: { "Authorization": `Basic ${token}` } };
  }

  getReziseri(ime?: string, page = 1, pageSize = 10): Observable<{ data: Reziser[], total: number }> {
    let params = new HttpParams().set('Page', page).set('PageSize', pageSize);
    if (ime) params = params.set('ImePrezime', ime);
    return this.http.get<any>(this.baseUrl, { params, ...this.authHeader() })
      .pipe(map(res => ({ data: res.resultList || [], total: res.count || 0 })));
  }

  dodajReziser(reziser: InsertReziser) { return this.http.post(this.baseUrl, reziser, this.authHeader()); }
  updateReziser(id: number, reziser: InsertReziser) { return this.http.put(`${this.baseUrl}/${id}`, reziser, this.authHeader()); }
  deleteReziser(id: number) { return this.http.delete(`${this.baseUrl}/${id}`, this.authHeader()); }
}
