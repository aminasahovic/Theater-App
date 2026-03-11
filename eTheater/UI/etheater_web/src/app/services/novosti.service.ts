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
export interface OdgovorKomentar {
  id: number;
  komentariObavijestiId: number;
  korisnikId: number;
  imeKorisnika: string;
  prezimeKorisnika: string;
  textOdgovora: string;
  datum: string;
}


export interface KomentarObavijest {
  id: number;
  obavijestId: number;
  imeKorisnika: string;
  prezimeKorisnika: string;
  text: string;
  datum: string;
  brojOdgovora: number;
}

export interface PagedResult<T> {
  resultList: T[];
  count: number;
}

@Injectable({ providedIn: 'root' })
export class NovostiService {
  private baseUrl = `${ApiKonstante.baseUrl}/Obavijest`;
  private komentariBaseUrl = `${ApiKonstante.baseUrl}/KomentarObavijest`;
  private odgovoriBaseUrl = `${ApiKonstante.baseUrl}/OdgovorKomentar`;

  constructor(private http: HttpClient, private auth: AuthService) {}

  private authHeader() {
    if (!this.auth.username || !this.auth.password) return {};
    const token = btoa(`${this.auth.username}:${this.auth.password}`);
    return { headers: { Authorization: `Basic ${token}` } };
  }
getOdgovoriByKomentar(komentarId: number, page = 1, pageSize = 5): Observable<PagedResult<OdgovorKomentar>> {
  const params = new HttpParams()
    .set('KomentariObavijestiId', komentarId)
    .set('Page', page)
    .set('PageSize', pageSize);
  return this.http.get<any>(`${this.odgovoriBaseUrl}/GetByKomentarId`, { params, ...this.authHeader() })
    .pipe(map(res => ({ resultList: res.resultList || [], count: res.count || 0 })));
}

deleteOdgovorKomentar(id: number): Observable<void> {
  return this.http.delete<void>(`${this.odgovoriBaseUrl}/${id}`, this.authHeader());
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

  getKomentariByObavijest(obavijestId: number, page: number, pageSize: number): Observable<PagedResult<KomentarObavijest>> {
    let params = new HttpParams()
      .set('ObavijestiId', obavijestId)
      .set('Page', page)
      .set('PageSize', pageSize);

    return this.http.get<any>(`${this.komentariBaseUrl}/GetByObavijest`, { params, ...this.authHeader() })
      .pipe(map(res => ({
        resultList: res.resultList || [],
        count: res.count || 0
      })));
  }

  deleteKomentarObavijest(id: number): Observable<void> {
    return this.http.delete<void>(`${this.komentariBaseUrl}/${id}`, this.authHeader());
  }
}
