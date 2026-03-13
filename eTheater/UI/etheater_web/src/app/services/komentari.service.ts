import { Injectable } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable, map } from 'rxjs';
import { ApiKonstante } from '../api-konstante';
import { AuthService } from './auth.service';

export interface PagedResult<T> {
  resultList: T[];
  count: number;
}
export interface KomentarPredstava {
  id: number;
  korisnikId?: number;
  predstavaId: number;
  imeKorisnika: string;
  prezimeKorisnika: string;
  komentar: string;
  ocjena?: number;
  datum: string;
}
@Injectable({ providedIn: 'root' })
export class KomentariService {
  private baseUrl = `${ApiKonstante.baseUrl}/KomentarPredstava`;

  constructor(private http: HttpClient, private auth: AuthService) {}

  private authHeader() {
    if (!this.auth.username || !this.auth.password) return {};
    const token = btoa(`${this.auth.username}:${this.auth.password}`);
    return { headers: { Authorization: `Basic ${token}` } };
  }

  getKomentari(predstavaId: number, page: number, pageSize = 3): Observable<PagedResult<KomentarPredstava>> {
    let params = new HttpParams()
      .set('PredstavaId', predstavaId)
      .set('Page', page)
      .set('PageSize', pageSize);

    return this.http.get<any>(`${this.baseUrl}/ByPredstava`, { params, ...this.authHeader() })
      .pipe(map(res => ({ resultList: res.resultList || [], count: res.count || 0 })));
  }

  deleteKomentar(id: number): Observable<void> {
    return this.http.delete<void>(`${this.baseUrl}/${id}`, this.authHeader());
  }
}
