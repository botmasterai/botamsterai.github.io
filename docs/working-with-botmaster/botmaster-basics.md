# Botmaster Basics

### Bot object

Hopefully, by now you've gathered your credentials for at least one platform and got some basic bot running. We remember from the [quickstart](/getting-started/quickstart) and the various Setup guides in [getting-started](/getting-started) that we can start a botmaster project like this:


```js
const Botmaster = require('botmaster');

const botmaster = new Botmaster();
.
. // full settings objects omitted for brevity
.
const messengerBot = new Botmaster.botTypes.MessengerBot(messengerSettings);
const slackBot = new Botmaster.botTypes.SlackBot(slackSettings);
const socketioBot = new Botmaster.botTypes.SocketioBot(socketioSettings));
const twitterBot = new Botmaster.botTypes.TwitterBot(twitterSettings);
const telegramBot = new Botmaster.botTypes.TelegramBot(telegramSettings);

botmaster.addBot(messengerBot);
botmaster.addBot(slackBot);
botmaster.addBot(twitterBot);
botmaster.addBot(socketioBot);
botmaster.addBot(telegramBot);
.
.
.
```

As it turns out, bot objects are really the ones running the show in the Botmaster framework. Your `botmaster` object is simply a central point of control for you to manage all of your bots. Botmaster assumes that most of your bots will have a central bit of code that you don't want to have to replicate for every platform/bot instance. Which should make sense.

Although the point of botmaster is for developers to do something like this after declaring the botmaster instance:

```js
botmaster.on('update', (bot, update) => {
  // do stuff with your bot and update here
});
```

One could (but shouldn't) just as well do:

```js
messengerBot.on('update', (update) => {
  // do stuff with your messenger bot here
});

// this applies to all the bot objects that would have been declared separately.
```

I say one shouldn't do that here because the only reason why this callback would work in this situation is because we've already called `botmaster.addBot(messengerBot)`. If we hadn't done that, we would have to mount the `messengerBot` object onto an express app ourselves. See [writing your own bot class](/working-with-botmaster/writing-your-own-bot-class) to read more on this.

The `update` object in the event callback is the same as the botmaster `update` one you would get in the botmaster update callback. Of course the `messenger.on(...)` piece of code would only apply to your `messengerBot` instance and not the others.

As seen, bot instances can be accessed directly within an `update` event. Because you might want to act differently on bots of a certain type or log information differently based on type, every bot comes with a `bot.type` parameter that is one of: `messenger`, `slack`, `twitter`, `socketio`, `telegram` or whatever third-party bot class you might have installed or created.

It is important to note here, that you can have multiple bot objects for a certain type. I'm sure you can find reasons for why you would want to do this. This is important to mention, as you might have, say, 2 bots of type `messenger` dealt with via Botmaster. You might want to do platform specific code by doing the following:

```js
botmaster.on('update', (bot, update) => {
  if (bot.type === 'messenger' {
    // do messenger specific stuff
    return;
  })
})
```

Then you might want to do bot object specific code. You would do this as such:

```js
botmaster.on('update', (bot, update) => {
  if (bot.type === 'messenger' {
    // do messenger specific stuff
    if (bot.id === 'YOUR_BOT_ID') {// this will be the user id of bot for messenger
      // do bot object specific stuff
      return;
    }
  })
})
```

Or if you declared your bots and botmaster as in the beginning of this section, you might have done the following:

```js
const Botmaster = require('botmaster');
const botmaster = new Botmaster();
// These are some of the bot classes that come with Botmaster
const Messengerbot = Botmaster.botTypes.MessengerBot;
const SlackBot = Botmaster.botTypes.SlackBot;
const TwitterBot = Botmaster.botTypes.TwitterBot;
.
. // full settings objects omitted for brevity
.
const messengerBot1 = new MessengerBot(messengerSettings1);
const messengerBot2 = new MessengerBot(messengerSettings2);
const slackBot = new SlackBot(slackSettings);
const twitterBot = new TwitterBot(twitterSettings);

botmaster.addBot(messengerBot);
botmaster.addBot(slackBot);
botmaster.addBot(twitterBot);

botmaster.on('update', (bot, update) => {
  if (bot.type === 'messenger' {
    // do messenger bot specific stuff


    if (bot === messengerBot1) { // without using ids
      // do messengerBot1 specific stuff
    }
    return;
  })
})
```

>Botmaster does not assure you that the `id` parameter of the `bot` object will exist upon instantiation. the `id` is only assured to be there once an update has been received by the bot. This is because some ids aren't known until botmaster knows 'who' the message was sent to (i.e. what id your bot should have).

I'll note quickly that each bot object created comes from one of the various bot classes as seen above. They act in the same way on the surface (because of heavy standardization), but have a few idiosynchrasies here and there.

Also useful to note is that you can access all the bots added to botmaster by doing `botmaster.bots`. you can also use `botmastet.getBot` or `botmaster.getBots` to get a specific bot (using type or id);

It is important to take note of the `addBot` syntax as you can create your own Bot class that extends the `Botmaster.botTypes.BaseBot` class. For instance, you might want to create your own class that supports your pre-existing messaging standards. Have a look at the [working with a botmaster supported bot class ](working-with-botmaster/writing-a-botmaster-supported-bot-class-readme.md) documentation to learn how to do this.

### Settings

Botmaster can be started with a so-called `botmasterSettings` object. It has the following parameters:
The `botmasterSettings` object has the following parameters:

| Parameter | Description
|--- |---
| port  | (__optional__) The port to use for your webhooks (see [webhooks](#webhooks) to understand more about webhooks). This will only be used if the `app` parameter is not provided. Otherwise, it will be ignored
| app  | (__optional__) An `express.js` app object to mount the `webhookEnpoints` onto. If you choose to do this, it is assumed that you will be starting your own express server and this won't be done by Botmaster. Unless you also specify a `server` parameter, `botmaster.server` will be `undefined`

>`botsSettings` and `server` parameters have been deprecated in version 2.2.3. Please use `addBot` instead of botsSettings and set the socketio server in your socketSettings object.

Using botsSettings would look something like this if you want to set the port:

```js
const Botmaster = require('botmaster');

const botmasterSettings = {
  // by default botmaster will start an express server that listens on port 3000
  // you can pass in a port argument here to change this default setting:
  port: 3001
}

const botmaster = new Botmaster(botmasterSettings);

.
. // rest of code adding bots to botmaster etc
.

```

>Please note, unless you are passing in an `app` object to the settings, it is assumed that you don't want to deal with anything relating to an http server. That is, botmaster will create an express server under the hood and expose both: `botmaster.app` and `botmaster.server`.

#### Setting `botmasterSettings` to use Botmaster with your own express() app

Here's an example on how to do so if you are setting your credentials in your environment variables:

```js
const express = require('express');
const Botmaster = require('botmaster');

const app = express();
const port = 3000;
const botmasterSettings = { app: app };
const botmaster = new Botmaster(botmasterSettings);

// settings and adding those to botmaster
const telegramSettings = {
  credentials: {
    authToken: process.env.TELEGRAM_TOKEN,
  },
  webhookEndpoint: '/webhook1234/',
};

const messengerSettings = {
  credentials: {
    verifyToken: process.env.MESSENGER_VERIFY_TOKEN,
    pageToken: process.env.MESSENGER_PAGE_TOKEN,
    fbAppSecret: process.env.FACEBOOK_APP_SECRET,
  },
  webhookEndpoint: '/webhook1234/',
};

const messengerBot = new Botmaster.botTypes.MessengerBot(messengerSettings);
const telegramBot = new Botmaster.botTypes.TelegramBot(telegramSettings);

botmaster.addBot(messengerBot);
botmaster.addBot(telegramBot);
////////

botmaster.on('update', (bot, update) => {
  bot.sendMessage({
    recipient: {
      id: update.sender.id,
    },
    message: {
      text: 'Well right back at you!',
    },
  });
});

// start server on the specified port and binding host
app.listen(port, '0.0.0.0', () => {
  // print a message when the server starts listening
  console.log(`Running App on port: ${port}`);
});
```

#### Setting `botmasterSettings` to use Botmaster with your own express() app and own server object

This example is what you should base your code on if you are using socket.io and your own http server object rather than the default botmaster one.

Here's an example on how to do so if you are setting your credentials in your environment variables:

```js
const http = require('http');
const express = require('express');
const Botmaster = require('botmaster');

const app = express();
const myServer = http.createServer(app);
const port = 3000;
const botmasterSettings = { app: app };
const botmaster = new Botmaster(botmasterSettings);

// settings and adding those to botmaster
const telegramSettings = {
  credentials: {
    authToken: process.env.TELEGRAM_TOKEN,
  },
  webhookEndpoint: '/webhook1234/',
};

const socketioSettings = {
  id: 'SOME_ID',
  server: myServer,
};

const telegramBot = new Botmaster.botTypes.TelegramBot(telegramSettings);
const socketioBot = new Botmaster.botTypes.SocketioBot(socketioSettings);


botmaster.addBot(messengerBot);
botmaster.addBot(socketioBot);
////////

botmaster.on('update', (bot, update) => {
  bot.sendMessage({
    recipient: {
      id: update.sender.id,
    },
    message: {
      text: 'Well right back at you!',
    },
  });
});

// start server on the specified port and binding host
myServer.listen(port, '0.0.0.0', () => {
  // print a message when the server starts listening
  console.log(`Running App on port: ${port}`);
});
```

The difference between this example and the previous one is that in the previous, we are using the express helper `app.listen` which essentially wraps around the `http` `server.listen` and returns a server instance. Whereas here we are doing it all ourselves and use `myServer.listen`.

### Events

Botmaster is built on top of the EventEmitter node.js class. Which means it can emit events and most importantly for us here, it can listen onto them. By doing any of the following:

```js
botmaster.on('server running', (message) => {
  console.log(message);
});

botmaster.on('update', (bot, update) => {
  console.log(bot.type);
  console.log(update);
});

botmaster.on('error', (bot, err) => {
  console.log(bot.type);
  console.log(err.stack);
});
```

These are the only four listeners that you can listen onto in botmaster. Let's go though them briefly:

#### server running

This event will be emitted only if you are not managing your own server (i.e. you started botmaster without setting the `app` parameter). It is just here to notify you that the server has been started. You don't necessarily need to use it. But you might want to do things at this point.

#### update

This is really where all the magic happens. Whenever a message (update in Botmaster semantic) is sent into your application. Botmaster will parse it and format it into its [FB Messenger] standard. Along with it, you will get a `bot` object which is the underlying object into which the message was sent. Note that the updates are standardized as well as the methods to use from the bot object (i.e. sending a message). Read further down to see how those two objects work.

#### error

This event is thrown whenever an error internal to Botmaster occurs. I.e. if for some reason a misconfigured message was sent in. Or if some other kind of error occurred directly within Botmaster. It is good to listen onto this event and keep track of potential errors. Also, if you code an error within `botmaster.on`, and don't catch it, it will be caught by Botmaster and emitted in to `error`. So like this you have full control of what is going on and can log everything straight from there.


## Message/Update format

Standardization is at the heart of Botmaster. The framework was really created for that purpose. This means that messages coming from any platform have to have the same format.

In order to do that, the **Facebook Messenger message format** was chosen and adopted. This means that when your botmaster object receives an 'update' event from anywhere, you can be sure that it will be of the same format as a similar message that would come from Facebook Messenger.

### Incoming update

Typically, it would look something like this for a message with an image attachment. Independent of what platform the message comes from:

```js
{
  raw: <platform_specific_raw_update>,
  sender: {
    id: <id_of_sender>
  },
  recipient: {
    id: <id_of_the_recipent> // will typically be the bot's id
  },
  timestamp: <unix_miliseconds_timestamp>,
  message: {
    mid: <message_id>,
    seq: <message_sequence_id>,
    attachments: [
      {
        type: 'image',
        payload: {
          url: 'https://scontent.xx.fbcdn.net/v/.....'
        }
      }
    ]
  }
};
```

This allows developers to handle these messages in one place only rather than doing it in multiple places. For more info on the various incoming messages formats, read the messenger bot doc on webhooks at: https://developers.facebook.com/docs/messenger-platform/webhook-reference/message-received.

Currently, you will only get updates for `Messages` (and not delivery, echo notification etc) for all platforms. On Messenger, it is assumed that you don't want to get updates for delivery, read and echo. This can't be turned on at the moment, but will be in later versions as it might be a requirement.

#### Note on attachment types and conversions
Attachment type conversion on incoming updates works as such for __Twitter__:

| Twitter Type | Botmaster conversion
|--- |---
| photo | image
| video  | video
| gif  | video

!!!Yes `gif` becomes a `video`. because Twitter doesn't actually use gifs the way you would expect it to. It simply loops over a short `.mp4` video.

Also, here's an important caveat for Twitter bot developers who are receiving attachments. Image links that come in from the Twitter API will be private and not public, which makes using them quite tricky. You might need to make authenticated requests to do so. The twitterBot objects you will receive in the update will have a `bot.twit` object. Documentation for how to use this is available [here](https://github.com/ttezel/twit).

Receiving and sending attachments [the Botmaster way] is not yet supported on **Slack** as of version 2.2.3. However, Slack supports url unfurling (meaning if you send images and other types of media urls in your message, this will be shown in the messages and users won't just see a url). Also, because of how Botmaster is built (i.e. keep all information from the original message) you can find all the necessary information in the `update.raw` object of the update.

Attachment type conversion works as such for __Telegram__:

| Telegram Type | Botmaster conversion
|--- |---
| audio | audio
| voice  | audio
| photo  | image
| video  | video
| location  | location
| venue  | location

`contact` attachment types aren't supported in Messenger. So in order to deal with them in Botmaster, you will have to look into your `update.raw` object which is the standard Telegram update. You will find your contact object in `update.raw.contact`.

Also, concerning `location` and `venue` attachments. The url received in Botmaster for Telegram is a google maps one with the coordinates as query parameters. It looks something like this: `https://maps.google.com/?q=<lat>,<long>`

A few of you will want to use attachments with your `socket.io` bots. Because the Botmaster message standard is the Facebook Messenger one, everything is URL based. Which means it is left to the developer to store both incoming and outgoing attachments. A tutorial on how to deal with this will be up soon in the [Tutorials](/tutorials) section.

### Outgoing messages

Again, outgoing messages are expected to be formatted like messages the Messenger platform would expect. They will typically look something like this for a text message:

```js
const message = {
  recipient: {
    id: update.sender.id,
  },
  message: {
    text: 'Some arbitrary text of yours'
  },
}
```

and you would use this as such in code:

```js
botmaster.on('update', (bot, update) => {
  const message = {
    recipient: {
      id: update.sender.id,
    },
    message: {
      text: 'Some arbitrary text of yours'
    },
  };
  bot.sendMessage(message);
});
```

typically, you would want to perform some action upon confirmation that the message was sent or catch a potential error. doing so is done like this:

```js
botmaster.on('update', (bot, update) => {
  .
  .
  bot.sendMessage(message)

  .then((body) => {
    console.log(body);
  })

  .catch((err) => {
    console.log(err.message);
  })
});

```

The `body` part of the response has the following structure:


| Argument | Description
|--- |---
| raw | raw response body (response from the platform).
| recipient_id | id of user who sent the message
| message_id | id of message that was just sent
| sent_message | full object that was just sent after going through all the outgoing middlewares

You can also opt to use callbacks rather than promises and this would work as such:

```js
botmaster.on('update', (bot, update) => {
  .
  .
  bot.sendMessage(message, (err, body) => {
    if (err) {
      return console.log(err.message);
    }

    console.log(body);
  });
});
```

Typically, this method (and all its accompanying helper ones that follow) will hit all your setup outgoing middleware (read more about middleware [here](/working-with-botmaster/middleware) if you don't know about them yet). If you want to avoid that and ignore your setup middleware in certain situations, do something like this:

```js
botmaster.on('update', (bot, update) => {
  .
  .
  bot.sendMessage(message, { ignoreMiddleware: true })
});
```

And its signature is as follows:

`bot.sendMessage`

| Argument | Description
|--- |---
| message | a full valid messenger message object.
| sendOptions | (__optional__) an object containing options regarding the sending of the message. One of those options is: `ignoreMiddleware`.
| cb | (__optional__) callback function if you don't want to use botmaster with promises.

As you can see, the `sendMessage` method used is used directly from the bot object and not using the botmaster one.

Because you might not always want to code in a complex json object just to send in a simple text message or photo attachment, Botmaster comes with a few helper methods that can be used to send messages with less code:

`bot.sendMessageTo`

| Argument | Description
|--- |---
| message | an object without the recipient part. In the previous example, it would be `message.message`.
| recipientId  | a string representing the id of the user to whom you want to send the message.
| sendOptions | (__optional__) an object containing options regarding the sending of the message. One of those options is: `ignoreMiddleware`.
| cb | (__optional__) callback function if you don't want to use botmaster with promises.

`bot.sendTextMessageTo`

| Argument | Description
|--- |---
| text | just a string with the text you want to send to your user
| recipientId  | a string representing the id of the user to whom you want to send the message.
| sendOptions | (__optional__) an object containing options regarding the sending of the message. One of those options is: `ignoreMiddleware`.
| cb | (__optional__) callback function if you don't want to use botmaster with promises.

Typically used like so to send a text message to the user who just spoke to the bot:

```js
botmaster.on('update', (bot, update) => {
  bot.sendTextMessageTo('something super important', update.sender.id);
});
```

`bot.reply`

| Argument | Description
|--- |---
| update | an update object with a valid `update.sender.id`.
| text  | just a string with the text you want to send to your user
| sendOptions | (__optional__) an object containing options regarding the sending of the message. One of those options is: `ignoreMiddleware`.
| cb | (__optional__) callback function if you don't want to use botmaster with promises.

This is is typically used like so:

```js
botmaster.on('update', (bot, update) => {
  bot.reply(update, 'something super important!');
});
```

#### Attachments

`bot.sendAttachmentTo`

We'll note here really quickly that Messenger only takes in urls for file attachment (image, video, audio, file). Most other platforms don't support sending attachments in this way. So we fall back to sending the url in text which really results in a very similar output. Same goes for Twitter that doesn't support attachments at all.

| Argument | Description
|--- |---
| attachment | a valid Messenger style attachment. See [here](https://developers.facebook.com/docs/messenger-platform/send-api-reference) for more on that.
| recipientId  | a string representing the id of the user to whom you want to send the message.
| sendOptions | (__optional__) an object containing options regarding the sending of the message. One of those options is: `ignoreMiddleware`.
| cb | (__optional__) callback function if you don't want to use botmaster with promises.

This is the general attachment sending method that will always work for Messenger but not necessarily for other platforms as Facebook Messenger supports all sorts of attachments that other platforms don't necessarily support. So beware when using it. To assure your attachment will be sent to all platforms, use `bot.sendAttachmentFromURLTo`.

This is typically used as such for sending an image url.

```js
botmaster.on('update', (bot, update) => {
  const attachment = {
    type: 'image'
    payload: {
      url: "some image url you've got",
    },
  };
  bot.sendAttachment(attachment, update.sender.id);
});
```

`bot.sendAttachmentFromURLTo`

Just easier to use this to send standard url attachments. And URL attachments if used properly should work on all out-of-the-box platforms:

| Argument | Description
|--- |---
| type | string representing the type of attachment (audio, video, image or file)
| url  | the url to your file
| recipientId  | a string representing the id of the user to whom you want to send the message.
| sendOptions | (__optional__) an object containing options regarding the sending of the message. One of those options is: `ignoreMiddleware`.
| cb | (__optional__) callback function if you don't want to use botmaster with promises.

This is typically used as such for sending an image url.

```js
botmaster.on('update', (bot, update) => {
  bot.sendAttachmentFromURLTo('image', "some image url you've got", update.sender.id);
});
```

#### Status

`bot.sendIsTypingMessageTo`

To indicate that something is happening on your bots end, you can show your users that the bot is 'working' or 'typing' something. to do so, simply invoke sendIsTypingMessageTo.

| Argument | Description
|--- |---
| recipientId  | a string representing the id of the user to whom you want to send the message.
| sendOptions | (__optional__) an object containing options regarding the sending of the message. One of those options is: `ignoreMiddleware`.
| cb | (__optional__) callback function if you don't want to use botmaster with promises.

It is used as such:

```js
botmaster.on('update', (bot, update) => {
  bot.sendIsTypingMessageTo(update.sender.id);
});
```

It will only send a request to the platforms that support it. If unsupported, nothing will happen.


#### Buttons

Buttons will almost surely be part of your bot. Botmaster provides a method that will send what is assumed to be a decent way to display buttons throughout all platforms.

`bot.sendDefaultButtonMessageTo`

| Argument | Description
|--- |---
| buttonTitles | array of button titles (no longer than 10 in size).
| recipientId  | a string representing the id of the user to whom you want to send the message.
| textOrAttachment  | (__optional__) a string or an attachment object similar to the ones required in `bot.sendAttachmentTo`. This is meant to provide context to the buttons. I.e. why are there buttons here. A piece of text or an attachment could detail that. If not provided,  text will be added that reads: 'Please select one of:'. This is only optional if none of sendOptions and cb is specified
| sendOptions | (__optional__) an object containing options regarding the sending of the message. One of those options is: `ignoreMiddleware`.
| cb | (__optional__) callback function if you don't want to use botmaster with promises.

The function defaults to sending `quick_replies` in Messenger, setting `Keyboard buttons` in Telegram, buttons in Slack and simply prints button titles one on each line in Twitter as it doesn't support buttons. The user is expecting to type in their choice in Twitter. In the socketio implementation, the front-end/app developer is expected to write the code that would display the buttons on their front-end.

It is used as such:

```js
botmaster.on('update', (bot, update) => {
  const buttonArray = ['button1', 'button2'];
  bot.sendDefaultButtonMessageTo(buttonArray, update.sender.id,
    'Please select "button1" or "button2"');
});
```

>If you will be using either of `sendOptions` or `cb`, you will need to specify `textOrAttachment`.


#### Cascade

In order to send a cascade of messages (i.e. multiple messages one after another), you might want to have a look at both of these methods:

`bot.sendCascadeTo`

| Argument | Description
|--- |---
| messageArray | Array of messages in a format as such: [{text: 'something'}, {message: someMessengerValidMessage}] read below to see valid keys.
| recipientId  | a string representing the id of the user to whom you want to send the message.

As you might have guessed, Botmaster assures you that the objects in the messageArray will be sent in order. Furthermore, the objects of the messageArray must be of a certain form where valid params are the following:

```js
{
  raw: SOME_VALID_RAW_MESSAGE, // the same object as one you would send with sendRaw()
  message: SOME_VALID_MESSENGER_MESSAGE, // the same object as one you would send with sendMessage() (i.e. the recipientId won't be taken into account!)
  buttons: SOME_ARRAY_OF_BUTTON_TITLES, // same as what you would do with: sendDefaultButtonMessageTo. If you will be sending attachments/text alongside it, add them in the following fields. If both are present, the attachment will be used.
  attachment: SOME_ATTACHMENT, // same object format as in: sendAttachmentTo()
  text: 'some text', // same as when using sendTextMessageTo()
  isTyping: SOME_TRUTHY_VALUE, // will call sendIsTypingMessageTo() on the recipientId used in sendCascade.
}
```

>It is important to note that all these parameters will be hit in the shown order if present. I.e. if `raw` is present, `message` will not be hit nor will `buttons` be hit etc.

You could typically use this as such:

```js
botmaster.on('update', (bot, update) => {
  const rawMessage = SOME_RAW_PLATFORM_MESSAGE;

  const fullMessage = {
    recipient: {
      id: someUserId, // note that I am not using update.sender.id on purpose here, so as to show that this overrides the recipientId from the sendCascade Method
    },
    message: {
      text: 'Some arbitrary text of yours'
    },
  };

  const buttonsArray = ['button1', 'button2'];
  const textForButtons = 'Please select one of the two buttons';

  const someText = 'some text message after all this';

  bot.sendCascadeTo([
    { raw: rawMessage},
    { message: fullMessage },
    { isTyping: true },
    { buttons: buttonsArray,
      text: textForButtons
    },
    { isTyping: true },
    { text: someText },
  ], update.sender.id)
});

```
Where our `recipientId` is set to `update.sender.id`.

In this example, the bot will send a rawMessage and then a botmaster supported message to the platform (both these messages will not take into consideration the recipientId (update.sender.id) set in sendCascade). Then it will send a button message and then a standard text message. Both these last messages will be sent to the specified recipientId (again, update.sender.id). Note that before each message sent to the recipient, I also send an 'isTyping' message to the recipient. I purposefully do not do so for the first two messages as it is assumed here that those messages are not being sent to the recipient, but to some other user.

`bot.sendTextCascadeTo`

| Argument | Description
|--- |---
| textMessageArray | Array of strings that you want to send to the user in sequences.
| recipientId  | a string representing the id of the user to whom you want to send the message.

This method is really just a helper for calling `bot.sendCascadeTo`. It just allows developers to use the method with an array of texts rather than an array of objects.

Something like this will do:

```js
bot.sendTextCascadeTo(['message1', 'message2'], user.sender.id);
```

`sendOptions` is an optional argument that can take in the following parameters (for now)

| key/option |  Description
|--- |---
| ignoreMiddleware | outgoing middleware will not be hit if this parameter is set to true (or any truthy value)

If you want to learn more about middleware and why you might want to use any of these options, read more about middleware [here](/working-with-botmaster/middleware)