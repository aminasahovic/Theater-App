import { HttpClient, HttpParams } from "@angular/common/http";
import { AuthService } from "./auth.service";
import { ApiKonstante } from "../api-konstante";
import { Injectable } from "@angular/core";

@Injectable({ providedIn: 'root' })
export class RepertoarService {

    private baseUrl = `${ApiKonstante.baseUrl}/Repertoar`;
    private baseUrlbase = `${ApiKonstante.baseUrl}`;

    constructor(private http: HttpClient, private auth: AuthService) { }

    private authHeader() {
        const token = btoa(`${this.auth.username}:${this.auth.password}`);
        return { headers: { Authorization: `Basic ${token}` } };
    }

    getRepertoari(filter: any) {
        let params = new HttpParams()
            .set('Page', filter.page)
            .set('PageSize', filter.pageSize);

        if (filter.naziv) params = params.set('Naziv', filter.naziv);
        if (filter.pocetakDatum) params = params.set('PocetakDatum', filter.pocetakDatum);

        return this.http.get<any>(this.baseUrl, { params, ...this.authHeader() });
    }

    getRepertoarIzvedbe(repertoarId: number) {
        return this.http.get<any>(
            `${this.baseUrlbase}/RepertoarIzvedba/Izvedbe/${repertoarId}`,
            this.authHeader()
        );
    }
    addRepertoar(data: any) {
        return this.http.post<number>(`${ApiKonstante.baseUrl}/Repertoar`, data, this.authHeader());
    }

    addRepertoarIzvedba(data: any) {
        return this.http.post(`${this.baseUrlbase}/RepertoarIzvedba`, data, this.authHeader());
    }
    updateRepertoar(id: number, data: any) {
        return this.http.put(`${this.baseUrl}/${id}`, data, this.authHeader());
    }

    updateRepertoarIzvedba(id: number, data: any) {
        return this.http.put(`${this.baseUrlbase}/RepertoarIzvedba/${id}`, data, this.authHeader());
    }
    deleteRepertoarIzvedba(repertoarIzvedbaId: any) {
        console.log(repertoarIzvedbaId);

        return this.http.delete(`${this.baseUrlbase}/RepertoarIzvedba/${repertoarIzvedbaId}`, this.authHeader());
    }
    deleteRepertoar(repertoarId: number) {
        return this.http.delete(`${this.baseUrl}/${repertoarId}`, this.authHeader());
    }

}
