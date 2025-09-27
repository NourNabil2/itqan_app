// ============= Member Notes Widgets - كلاسات منفصلة =============
import 'package:flutter/material.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/data/models/member/member.dart';
import 'package:itqan_gym/data/models/member/member_notes.dart';
import 'package:itqan_gym/providers/member_provider.dart';
import 'package:itqan_gym/screens/member/member_notes/widgets/error_notes_widget.dart';
import 'package:itqan_gym/screens/member/member_notes/widgets/loading_notes_widget.dart';
import 'package:provider/provider.dart';
import '../widgets/notes/detailes_notes_section.dart';
import '../widgets/notes/general_notes_section.dart';
import '../widgets/notes/notes_overview_card.dart';


class MemberNotesTab extends StatelessWidget {
  final Member member;
  final VoidCallback onEditGeneralNotes;
  final VoidCallback onAddDetailedNote;
  final VoidCallback onViewAllNotes;
  final Function(MemberNote) onViewNoteDetails;

  const MemberNotesTab({
    super.key,
    required this.member,
    required this.onEditGeneralNotes,
    required this.onAddDetailedNote,
    required this.onViewAllNotes,
    required this.onViewNoteDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<MemberNotesProvider>(
      builder: (context, notesProvider, child) {
        //  تحميل الملاحظات تلقائياً إذا لم تكن محملة
        if (!notesProvider.isInitialized) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            notesProvider.loadMemberNotes(member.id);
          });
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(SizeApp.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //  قسم الملاحظة العامة
              RepaintBoundary(
                child: GeneralNotesSection(
                  member: member,
                  onEditNotes: onEditGeneralNotes,
                ),
              ),

              SizedBox(height: SizeApp.s20),

              //  معالجة الحالات المختلفة للملاحظات المفصلة
              if (notesProvider.isLoading)
                const LoadingNotesWidget()
              else if (notesProvider.error != null)
                ErrorNotesWidget(
                  error: notesProvider.error!,
                  onRetry: () {
                    notesProvider.clearError();
                    notesProvider.loadMemberNotes(member.id);
                  },
                )
              else
              //  قسم الملاحظات المفصلة
                DetailedNotesSection(
                  notesProvider: notesProvider,
                  onAddNote: onAddDetailedNote,
                  onViewAll: onViewAllNotes,
                  onNoteDetails: onViewNoteDetails,
                ),

              //  كارت ملخص الملاحظات (اختياري) todo::
              // if (notesProvider.allNotes.isNotEmpty) ...[
              //   SizedBox(height: SizeApp.s20),
              //   RepaintBoundary(
              //     child: NotesOverviewCard(
              //       notesProvider: notesProvider,
              //       onViewAll: onViewAllNotes,
              //     ),
              //   ),
              // ],
            ],
          ),
        );
      },
    );
  }
}