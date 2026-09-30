import 'package:flutter/material.dart';

class TrackJobStatusBar extends StatelessWidget {
  const TrackJobStatusBar({
    super.key,
    required this.status,
    this.compact = false,
  });

  final String status;
  final bool compact;

  static const List<StatusStep> steps = [
    StatusStep(
      key: 'PENDING',
      title: 'Reported',
      shortLabel: 'Pending',
      icon: Icons.assignment_late_outlined,
      color: Color(0xFFF59E0B), // Vibrant Amber
    ),
    StatusStep(
      key: 'ASSIGNED',
      title: 'Assigned',
      shortLabel: 'Assigned',
      icon: Icons.engineering_outlined,
      color: Color(0xFF0284C7), // Sky Blue
    ),
    StatusStep(
      key: 'IN_PROGRESS',
      title: 'In Progress',
      shortLabel: 'In Progress',
      icon: Icons.build_circle_outlined,
      color: Color(0xFF2563EB), // Electric Blue
    ),
    StatusStep(
      key: 'COMPLETED',
      title: 'Repaired & Cleared',
      shortLabel: 'Completed',
      icon: Icons.verified_rounded,
      color: Color(0xFF10B981), // Emerald Green
    ),
  ];

  int _currentIndex() {
    final s = status.toUpperCase().trim();
    if (s == 'COMPLETED') return 3;
    if (s == 'IN_PROGRESS') return 2;
    if (s == 'ASSIGNED') return 1;
    return 0; // PENDING or default
  }

  @override
  Widget build(BuildContext context) {
    final currentIdx = _currentIndex();
    final currentStep = steps[currentIdx];

    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: currentStep.color,
                  boxShadow: [
                    BoxShadow(
                      color: currentStep.color.withValues(alpha: 0.6),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Stage ${currentIdx + 1}/4: ${currentStep.shortLabel}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: currentStep.color,
                ),
              ),
              const Spacer(),
              Text(
                '${((currentIdx + 1) / 4 * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (currentIdx + 1) / 4,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(currentStep.color),
              minHeight: 6,
            ),
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: currentStep.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(currentStep.icon, color: currentStep.color, size: 16),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Track Work Status',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: currentStep.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: currentStep.color.withValues(alpha: 0.3)),
                ),
                child: Text(
                  currentStep.shortLabel.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: currentStep.color,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (int i = 0; i < steps.length; i++) ...[
                _buildStepNode(i, currentIdx),
                if (i < steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 3,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: i < currentIdx
                            ? steps[i].color
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (int i = 0; i < steps.length; i++)
                SizedBox(
                  width: 68,
                  child: Text(
                    steps[i].shortLabel,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: i == currentIdx ? FontWeight.w800 : FontWeight.w500,
                      color: i == currentIdx
                          ? steps[i].color
                          : (i < currentIdx ? Colors.grey.shade700 : Colors.grey.shade400),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepNode(int index, int currentIdx) {
    final isPassed = index < currentIdx;
    final isCurrent = index == currentIdx;
    final step = steps[index];

    Color nodeColor = Colors.grey.shade300;
    Color iconColor = Colors.grey.shade500;

    if (isPassed || isCurrent) {
      nodeColor = step.color;
      iconColor = Colors.white;
    }

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: isCurrent ? Colors.white : nodeColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: (isCurrent || isPassed) ? step.color : Colors.grey.shade400,
          width: isCurrent ? 2.5 : 1,
        ),
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: step.color.withValues(alpha: 0.4),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Center(
        child: isPassed
            ? const Icon(Icons.check, size: 14, color: Colors.white)
            : (isCurrent
                ? Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: step.color,
                    ),
                  )
                : Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: iconColor,
                    ),
                  )),
      ),
    );
  }
}

class StatusStep {
  const StatusStep({
    required this.key,
    required this.title,
    required this.shortLabel,
    required this.icon,
    required this.color,
  });

  final String key;
  final String title;
  final String shortLabel;
  final IconData icon;
  final Color color;
}
