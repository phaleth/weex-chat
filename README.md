# WeexChat

To start the Phoenix server:

- Run `mix setup` to install and setup dependencies
- Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now visit [`localhost:4000`](http://localhost:4000) from your browser.

## Entity-Relationship Diagram

```mermaid
erDiagram

Message {
  text content
  id user_id
  id channel_id
}

Channel {
  string name
  id creator_id
  id member_id
  boolean user_is_guest
}

ChannelSetting {
  id channel_id
  boolean allow_guests
}

User {
  string username
  string email
  string hashed_password
  naive_datetime confirmed_at
}

UserSetting {
  id user_id
  id color_theme_id
}

ColorTheme {
  id creator_id
  text color_map
}

UserChannel {
  id user_id
  id channel_id
}

User ||--O{ Message : "has_many"
User }O--O{ UserChannel : "has_many"
UserChannel }O--O{ Channel : "has_many"
User ||--|| UserSetting : "has_one"
Channel ||--O{ Message : "has_many"
Channel ||--|| ChannelSetting : "has_one"
ColorTheme ||--|{ UserSetting : "has_many"
```
