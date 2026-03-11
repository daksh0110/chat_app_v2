import 'package:my_app/modal/screens/message/message_modal.dart';

MessageStatus statusMap(String status) {
  switch (status) {
    case "sending":
      return MessageStatus.sending;
    case "sent":
      return MessageStatus.sent;
    case "delivered":
      return MessageStatus.delivered;
    case "read":
      return MessageStatus.read;
    case "failed":
      return MessageStatus.failed;
    default:
      return MessageStatus.sending;
  }
}
