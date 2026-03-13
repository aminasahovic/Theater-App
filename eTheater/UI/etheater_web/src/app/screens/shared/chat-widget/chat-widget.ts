import { Component, ViewChild, ElementRef, AfterViewChecked, ChangeDetectorRef } from '@angular/core';
import { AdminChatService, ChatMessage } from '../../../services/admin-chat.service';

@Component({
  selector: 'app-chat-widget',
  templateUrl: './chat-widget.html',
  styleUrls: ['./chat-widget.css'],
  standalone: false
})
export class ChatWidgetComponent implements AfterViewChecked {
  @ViewChild('messagesContainer') messagesContainer!: ElementRef;

  isOpen = false;
  isLoading = false;
  inputText = '';
  messages: ChatMessage[] = [];

  private lastResponse = '';
  private shouldScroll = false;

  constructor(
    private chatService: AdminChatService,
    private cdr: ChangeDetectorRef
  ) {}

  ngAfterViewChecked(): void {
    if (this.shouldScroll) {
      this.scrollToBottom();
      this.shouldScroll = false;
    }
  }

  toggleChat(): void {
    this.isOpen = !this.isOpen;
    if (this.isOpen) this.shouldScroll = true;
  }

  async sendMessage(): Promise<void> {
    const text = this.inputText.trim();
    if (!text || this.isLoading) return;

    this.inputText = '';
    this.messages.push({ text, isAdmin: true, time: new Date() });
    this.isLoading = true;
    this.shouldScroll = true;
    this.cdr.detectChanges();

    try {
      const reply = await this.chatService.sendMessage(text, this.lastResponse);
      this.lastResponse = reply;
      this.messages.push({ text: reply, isAdmin: false, time: new Date() });
    } catch {
      this.messages.push({
        text: 'Greška pri komunikaciji s AI servisom. Pokušajte ponovo.',
        isAdmin: false,
        time: new Date()
      });
    } finally {
      this.isLoading = false;
      this.shouldScroll = true;
      this.cdr.detectChanges();
    }
  }

  onKeydown(event: KeyboardEvent): void {
    if (event.key === 'Enter' && !event.shiftKey) {
      event.preventDefault();
      this.sendMessage();
    }
  }

  formatMessage(text: string): string {
    if (!text) return '';
    return text
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/(^|\n)([ \t]*)\*[ \t]+/g, '$1$2• ')
      .replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>')
      .replace(/\*([^\s*](?:[^*]*[^\s*])?)\*/g, '<em>$1</em>')
      .replace(/\n/g, '<br>');
  }

  private scrollToBottom(): void {
    try {
      const el = this.messagesContainer?.nativeElement;
      if (el) el.scrollTop = el.scrollHeight;
    } catch {}
  }
}
