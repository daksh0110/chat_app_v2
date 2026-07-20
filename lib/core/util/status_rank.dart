int statusRank(String status) {
  switch (status) {
    case "sending":
      return 0;
    case "sent":
      return 1;
    case "delivered":
      return 2;
    case "read":
      return 3;
    default:
      return -1;
  }
}
