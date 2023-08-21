# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     WeexChat.Repo.insert!(%WeexChat.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias WeexChat.Chat.Message
alias WeexChat.Repo

%Message{}
|> Message.changeset(%{
  user_id: nil,
  from: "-->",
  content: "phaleth (~phaleth@user/phaleth) has joined #lfe"
})
|> Repo.insert()

Process.sleep(Enum.random(5..10))

%Message{}
|> Message.changeset(%{
  user_id: nil,
  from: "ℹ",
  content:
    "Topic for #lfe is \"Little Fighter Empire | https://discord.gg/MWrHgT4h | https://lf-empire.de/forum/\""
})
|> Repo.insert()

Process.sleep(Enum.random(5..10))

%Message{}
|> Message.changeset(%{
  user_id: nil,
  from: "ℹ",
  content: "Topic set by redacted (~redacted@user/redacted) on Sun, 15 Aug 2021 13:14:38"
})
|> Repo.insert()

Process.sleep(Enum.random(5..10))

%Message{}
|> Message.changeset(%{
  user_id: nil,
  from: "ℹ",
  content: "Channel #lfe: 6 nicks (1 op, 0 voices, 5 normals)"
})
|> Repo.insert()

Process.sleep(Enum.random(5..10))

%Message{}
|> Message.changeset(%{
  user_id: nil,
  from: "ℹ",
  content: "PvNotice(ChanServ): Yay things!"
})
|> Repo.insert()

Process.sleep(Enum.random(500..1000))

%Message{}
|> Message.changeset(%{
  user_id: nil,
  from: "ℹ",
  content: "Channel created on Tue, 15 Jun 2021 17:34:17"
})
|> Repo.insert()

Process.sleep(Enum.random(1000..3000))

%Message{}
|> Message.changeset(%{user_id: nil, from: "Guest", content: "hello everyone"})
|> Repo.insert()
