import { ComponentFixture, TestBed } from '@angular/core/testing';

import { RepertoarScreen } from './repertoar-screen';

describe('RepertoarScreen', () => {
  let component: RepertoarScreen;
  let fixture: ComponentFixture<RepertoarScreen>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [RepertoarScreen]
    })
    .compileComponents();

    fixture = TestBed.createComponent(RepertoarScreen);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
