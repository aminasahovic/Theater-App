import { ComponentFixture, TestBed } from '@angular/core/testing';

import { PredstavaDetails } from './predstava-details';

describe('PredstavaDetails', () => {
  let component: PredstavaDetails;
  let fixture: ComponentFixture<PredstavaDetails>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [PredstavaDetails]
    })
    .compileComponents();

    fixture = TestBed.createComponent(PredstavaDetails);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
