export interface Predstava {
  id: number;
  naziv: string;
  zanrId: number;
  opis: string;
  trajanje: number;
  godina: number;
  plakat?: string;
  isActive: boolean;
  reziserId: number;
}

export interface Zanr {
  id: number;
  naziv: string;
}

export interface Reziser {
  id: number;
  ime: string;
  prezime: string;
}

export interface PagedResult<T> {
  count: number;
  resultList: T[];
}
