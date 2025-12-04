import { Injectable } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable, map } from 'rxjs';
import { ApiKonstante } from '../api-konstante';
import { AuthService } from './auth.service';

export interface Novost {
  id: number;
  naslov: string;
  sadrzaj: string;
  datumObjave: string;
  slika?: string | null;
}

@Injectable({ providedIn: 'root' })
export class NovostiService {
  private baseUrl = `${ApiKonstante.baseUrl}/Obavijest`;

  constructor(private http: HttpClient, private auth: AuthService) {}

  private authHeader() {
    if (!this.auth.username || !this.auth.password) return {};
    const token = btoa(`${this.auth.username}:${this.auth.password}`);
    return { headers: { Authorization: `Basic ${token}` } };
  }

  getNovosti(filter: { page: number; pageSize: number; naslov?: string; datumObjave?: string | null }): Observable<{ data: Novost[]; count: number }> {
    let params = new HttpParams()
      .set('page', filter.page)
      .set('pageSize', filter.pageSize);

    if (filter.naslov) params = params.set('naslov', filter.naslov);
    if (filter.datumObjave) params = params.set('datumObjave', filter.datumObjave);

    return this.http.get<any>(`${this.baseUrl}`, { params, ...this.authHeader() })
      .pipe(map(res => ({ data: res.resultList || [], count: res.count || 0 })));
  }

  dodajNovost(novost: Partial<Novost>): Observable<Novost> {
    return this.http.post<Novost>(this.baseUrl, novost, this.authHeader());
  }

  updateNovost(novost: Novost): Observable<Novost> {
    return this.http.put<Novost>(`${this.baseUrl}/${novost.id}`, novost, this.authHeader());
  }

  deleteNovost(id: number): Observable<void> {
    return this.http.delete<void>(`${this.baseUrl}/${id}`, this.authHeader());
  }
}
