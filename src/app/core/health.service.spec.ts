import { TestBed } from '@angular/core/testing';
import { HttpTestingController, provideHttpClientTesting } from '@angular/common/http/testing';
import { provideHttpClient } from '@angular/common/http';

import { HealthService, HealthStatus } from './health.service';
import { environment } from '../../environments/environment';

describe('HealthService', () => {
  let service: HealthService;
  let http: HttpTestingController;

  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [HealthService, provideHttpClient(), provideHttpClientTesting()],
    });
    service = TestBed.inject(HealthService);
    http = TestBed.inject(HttpTestingController);
  });

  afterEach(() => http.verify());

  it('consulta o endpoint de health da API', () => {
    let recebido: HealthStatus | undefined;

    service.check().subscribe((r) => (recebido = r));

    const req = http.expectOne(`${environment.apiUrl}/health`);
    expect(req.request.method).toBe('GET');
    req.flush({ status: 'ok', database: 'ok' });

    expect(recebido).toEqual({ status: 'ok', database: 'ok' });
  });

  it('propaga erro quando a API está fora', () => {
    let erro: unknown;

    service.check().subscribe({ error: (e: unknown) => (erro = e) });

    http.expectOne(`${environment.apiUrl}/health`).flush('', {
      status: 503,
      statusText: 'Service Unavailable',
    });

    expect(erro).toBeTruthy();
  });
});
