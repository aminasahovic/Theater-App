import { Injectable } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable, map } from 'rxjs';
import { ApiKonstante } from '../api-konstante';
import { AuthService } from './auth.service';

export interface Glumac {
  id: number;
  ime: string;
  prezime: string;
  slika?: string;
}

export interface InsertGlumac {
  ime: string;
  prezime: string;
  slika?: string;
}

@Injectable({ providedIn: 'root' })
export class GlumciService {
  private baseUrl = `${ApiKonstante.baseUrl}/Glumac`;

  constructor(private http: HttpClient, private auth: AuthService) {}

  private authHeader() {
    if (!this.auth.username || !this.auth.password) return {};
    const token = btoa(`${this.auth.username}:${this.auth.password}`);
    return { headers: { "Authorization": `Basic ${token}` } };
  }

  getGlumci(ime?: string, page = 1, pageSize = 10): Observable<{ data: Glumac[], total: number }> {
    let params = new HttpParams()
      .set('Page', page)
      .set('PageSize', pageSize);

    if (ime) params = params.set('ImePrezime', ime);

    return this.http.get<any>(this.baseUrl, { params, ...this.authHeader() })
      .pipe(map(res => ({
        data: res.resultList || [],
        total: res.count || 0
      })));
  }

  dodajGlumca(glumac: InsertGlumac) {
    return this.http.post(this.baseUrl, glumac, this.authHeader());
  }

  updateGlumca(id: number, glumac: InsertGlumac) {
    return this.http.put(`${this.baseUrl}/${id}`, glumac, this.authHeader());
  }

  deleteGlumca(id: number) {
    return this.http.delete(`${this.baseUrl}/${id}`, this.authHeader());
  }
}
