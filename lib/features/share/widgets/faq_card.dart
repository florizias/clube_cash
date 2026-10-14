import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final List<FaqItem> faqItems = [
  FaqItem(
    question: 'Como ganhar pontos?',
    answer:
        'Você ganha pontos ao realizar compras nos parceiros participantes e cadastrar sua nota fiscal no aplicativo. '
        'Alguns parceiros também oferecem promoções com pontos extras.',
  ),
  FaqItem(
    question: 'Quanto tempo demora para os pontos caírem?',
    answer:
        'Após o envio da nota fiscal, a validação pode levar até 48 horas. '
        'Assim que for aprovada, os pontos são creditados automaticamente na sua conta.',
  ),
  FaqItem(
    question: 'Meus pontos expiraram?',
    answer:
        'Sim, seus pontos têm validade de 12 meses a partir da data em que foram creditados. '
        'Você será notificado quando estiverem próximos do vencimento para não perder seus benefícios.',
  ),
  FaqItem(
    question: 'Como resgatar recompensas?',
    answer:
        'Acesse a aba "Carteira" e selecione a opção de resgate. '
        'Você pode trocar seus pontos por dinheiro, descontos ou benefícios disponíveis no app.',
  ),
  FaqItem(
    question: 'A nota fiscal foi recusada, o que fazer?',
    answer:
        'Verifique se a imagem está legível e se contém todas as informações obrigatórias. '
        'Caso esteja tudo correto, você pode reenviar a nota ou entrar em contato com o suporte para análise.',
  ),
];

class FaqItem {
  final String question;
  final String answer;

  FaqItem({required this.question, required this.answer});
}

Widget faqCard({
  required BuildContext context,
  required int index,
  required int totalItems,
  required FaqItem item,
  required String query,
  ExpansibleController? controller,
}) {
  return Column(
    children: [
      Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          controller: controller,
          key: ValueKey('${item.question}-${query.trim()}'),
          initiallyExpanded: query.trim().isNotEmpty,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          iconColor: const Color(0xFF6B7280),
          collapsedIconColor: const Color(0xFF6B7280),
          title: RichText(
            text: highlightText(
              text: item.question,
              query: query,
              normalStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF0F1729)),
              highlightStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFFEF8F00)),
            ),
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: RichText(
                text: highlightText(
                  text: item.answer,
                  query: query,
                  normalStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: const Color(0xFF9CA3AF), height: 1.45),
                  highlightStyle: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFEF8F00),
                    backgroundColor: const Color(0xFFFFF3E0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      if (index != totalItems - 1) const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),
    ],
  );
}

TextSpan highlightText({required String text, required String query, required TextStyle normalStyle, required TextStyle highlightStyle}) {
  if (query.trim().isEmpty) {
    return TextSpan(text: text, style: normalStyle);
  }
  final lowerText = text.toLowerCase();
  final lowerQuery = query.toLowerCase();
  final spans = <TextSpan>[];
  int start = 0;
  while (true) {
    final index = lowerText.indexOf(lowerQuery, start);
    if (index < 0) {
      spans.add(TextSpan(text: text.substring(start), style: normalStyle));
      break;
    }
    if (index > start) {
      spans.add(TextSpan(text: text.substring(start, index), style: normalStyle));
    }
    spans.add(TextSpan(text: text.substring(index, index + query.length), style: highlightStyle));
    start = index + query.length;
  }
  return TextSpan(children: spans);
}
