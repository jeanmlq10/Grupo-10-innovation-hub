import 'package:flutter_test/flutter_test.dart';

import 'package:f_clean_template/features/profile/domain/models/trajectory_summary.dart';

void main() {
  test('sin actividad es "Nuevo"', () {
    expect(TrajectorySummary.empty.commitment, CommitmentLevel.newcomer);
    expect(TrajectorySummary.empty.fulfillment, 0);
  });

  test('calcula desempeño y compromiso', () {
    const s = TrajectorySummary(
      projectsCreated: 1,
      projectsCompleted: 1,
      tasksAssigned: 4,
      tasksCompleted: 3,
      participations: 2,
      comments: 2,
      requestsSent: 2,
      requestsAccepted: 2,
    );
    expect(s.collaboration, 0.8); // (2*2 + 1*2 + 2) / 10
    expect(s.fulfillment, 0.75);
    expect(s.quality, 1);
    expect(s.commitment, CommitmentLevel.high);
  });
}
