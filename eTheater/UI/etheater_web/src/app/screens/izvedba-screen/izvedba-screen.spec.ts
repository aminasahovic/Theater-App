import { ComponentFixture, TestBed } from '@angular/core/testing';

import { IzvedbaScreen } from './izvedba-screen';

describe('IzvedbaScreen', () => {
  let component: IzvedbaScreen;
  let fixture: ComponentFixture<IzvedbaScreen>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [IzvedbaScreen]
    })
    .compileComponents();

    fixture = TestBed.createComponent(IzvedbaScreen);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
