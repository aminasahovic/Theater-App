import { ComponentFixture, TestBed } from '@angular/core/testing';

import { NovostiScreenComponent } from './novosti-screen-component';

describe('NovostiScreenComponent', () => {
  let component: NovostiScreenComponent;
  let fixture: ComponentFixture<NovostiScreenComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [NovostiScreenComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(NovostiScreenComponent);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
