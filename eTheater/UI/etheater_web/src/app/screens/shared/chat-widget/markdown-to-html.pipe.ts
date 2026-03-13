import { Pipe, PipeTransform } from '@angular/core';

@Pipe({ name: 'markdownToHtml', standalone: false })
export class MarkdownToHtmlPipe implements PipeTransform {

  transform(value: string): string {
    if (!value) return '';

    return value
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/(^|\n)([ \t]*)\*[ \t]+/g, '$1$2• ')
      .replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>')
      .replace(/\*([^\s*](?:[^*]*[^\s*])?)\*/g, '<em>$1</em>')
      .replace(/\n/g, '<br>');
  }
}
