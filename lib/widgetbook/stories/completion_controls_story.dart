import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';


WidgetbookComponent buildCompletionControlsComponent() {
  return WidgetbookComponent(
    name: 'Completion Controls',
    useCases: [
      WidgetbookUseCase(
        name: 'Toggle Controls',
        builder: (_) => const _ToggleControls(),
      ),
      WidgetbookUseCase(
        name: 'Action Buttons',
        builder: (_) => const _ActionButtons(),
      ),
      WidgetbookUseCase(
        name: 'Page Indicators',
        builder: (_) => const _PageIndicators(),
      ),
      WidgetbookUseCase(
        name: 'Complete Control Panel',
        builder: (_) => const _CompleteControlPanel(),
      ),
    ],
  );
}

class _ToggleControls extends StatefulWidget {
  const _ToggleControls();

  @override
  State<_ToggleControls> createState() => _ToggleControlsState();
}

class _ToggleControlsState extends State<_ToggleControls> {
  bool _showPR = true;
  bool _blurBackground = false;
  bool _includeStats = true;
  bool _autoShare = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Toggle Controls',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[900]?.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[800]!),
              ),
              child: Column(
                children: [
                  _ToggleRowWrapper(
                    label: 'Show Personal Records',
                    value: _showPR,
                    onChanged: (value) => setState(() => _showPR = value),
                  ),
                  const SizedBox(height: 16),
                  _ToggleRowWrapper(
                    label: 'Blur Background',
                    value: _blurBackground,
                    onChanged: (value) => setState(() => _blurBackground = value),
                  ),
                  const SizedBox(height: 16),
                  _ToggleRowWrapper(
                    label: 'Include Detailed Stats',
                    value: _includeStats,
                    onChanged: (value) => setState(() => _includeStats = value),
                  ),
                  const SizedBox(height: 16),
                  _ToggleRowWrapper(
                    label: 'Auto-share to Social',
                    value: _autoShare,
                    onChanged: (value) => setState(() => _autoShare = value),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[900]?.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[800]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CURRENT SETTINGS',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Show PR: $_showPR\nBlur: $_blurBackground\nStats: $_includeStats\nAuto-share: $_autoShare',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Action Buttons',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            
            // Primary actions
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[900]?.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[800]!),
              ),
              child: Column(
                children: [
                  const Text(
                    'PRIMARY ACTIONS',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _ActionButtonWrapper(
                          label: 'Copy to Clipboard',
                          icon: Icons.copy,
                          isPrimary: true,
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ActionButtonWrapper(
                          label: 'Share',
                          icon: Icons.share,
                          isPrimary: true,
                          onTap: () {},
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Secondary actions
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[900]?.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[800]!),
              ),
              child: Column(
                children: [
                  const Text(
                    'SECONDARY ACTIONS',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _ActionButtonWrapper(
                          label: 'Save Image',
                          icon: Icons.download,
                          isPrimary: false,
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ActionButtonWrapper(
                          label: 'Edit',
                          icon: Icons.edit,
                          isPrimary: false,
                          onTap: () {},
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Close button
            _CloseButtonWrapper(onTap: () {}),
          ],
        ),
      ),
    );
  }
}

class _PageIndicators extends StatefulWidget {
  const _PageIndicators();

  @override
  State<_PageIndicators> createState() => _PageIndicatorsState();
}

class _PageIndicatorsState extends State<_PageIndicators> {
  int _currentPage = 0;
  final int _totalPages = 4;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Page Indicators',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[900]?.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[800]!),
              ),
              child: Column(
                children: [
                  _PageIndicatorsWrapper(
                    currentIndex: _currentPage,
                    count: _totalPages,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _currentPage > 0
                            ? () => setState(() => _currentPage--)
                            : null,
                        child: const Text('Previous'),
                      ),
                      Text(
                        '${_currentPage + 1} of $_totalPages',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _currentPage < _totalPages - 1
                            ? () => setState(() => _currentPage++)
                            : null,
                        child: const Text('Next'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Different page counts
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[900]?.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[800]!),
              ),
              child: const Column(
                children: [
                  Text(
                    'DIFFERENT PAGE COUNTS',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _PageIndicatorsWrapper(currentIndex: 0, count: 2),
                      _PageIndicatorsWrapper(currentIndex: 1, count: 3),
                      _PageIndicatorsWrapper(currentIndex: 2, count: 5),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompleteControlPanel extends StatefulWidget {
  const _CompleteControlPanel();

  @override
  State<_CompleteControlPanel> createState() => _CompleteControlPanelState();
}

class _CompleteControlPanelState extends State<_CompleteControlPanel> {
  bool _showPR = true;
  bool _blurBackground = false;
  final int _currentCard = 0;
  final int _totalCards = 3;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Complete Control Panel',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[900]?.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[800]!),
              ),
              child: Column(
                children: [
                  // Toggles
                  _ToggleRowWrapper(
                    label: 'Show Personal Records',
                    value: _showPR,
                    onChanged: (value) => setState(() => _showPR = value),
                  ),
                  const SizedBox(height: 12),
                  _ToggleRowWrapper(
                    label: 'Blur Background',
                    value: _blurBackground,
                    onChanged: (value) => setState(() => _blurBackground = value),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Page indicators
                  _PageIndicatorsWrapper(
                    currentIndex: _currentCard,
                    count: _totalCards,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: _ActionButtonWrapper(
                          label: 'Copy',
                          icon: Icons.copy,
                          isPrimary: true,
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ActionButtonWrapper(
                          label: 'Share',
                          icon: Icons.share,
                          isPrimary: true,
                          onTap: () {},
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  _CloseButtonWrapper(onTap: () {}),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper wrapper components
class _ToggleRowWrapper extends StatelessWidget {
  const _ToggleRowWrapper({
    required this.label,
    required this.value,
    this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          thumbColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? Colors.white
                : Colors.grey[600],
          ),
          trackColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? Colors.grey[700]
                : Colors.grey[800],
          ),
        ),
      ],
    );
  }
}

class _ActionButtonWrapper extends StatelessWidget {
  const _ActionButtonWrapper({
    required this.label,
    required this.icon,
    required this.isPrimary,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isPrimary ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isPrimary ? null : Border.all(color: Colors.grey[600]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isPrimary ? Colors.black : Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isPrimary ? Colors.black : Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CloseButtonWrapper extends StatelessWidget {
  const _CloseButtonWrapper({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(
          Icons.close,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}

class _PageIndicatorsWrapper extends StatelessWidget {
  const _PageIndicatorsWrapper({
    required this.currentIndex,
    required this.count,
  });

  final int currentIndex;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (index) {
        final isActive = index == currentIndex;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: isActive ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.grey[600],
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
