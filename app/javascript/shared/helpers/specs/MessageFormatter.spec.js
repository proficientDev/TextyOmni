import MessageFormatter from '../MessageFormatter';

describe('#MessageFormatter', () => {
  describe('content with links', () => {
    it('should format correctly', () => {
      const message =
        'TextyOmni \nSee more at https://www.textyomni.com';
      expect(new MessageFormatter(message).formattedMessage).toEqual(
        'TextyOmni<br>See more at <a rel="noreferrer noopener nofollow" href="https://www.textyomni.com" class="link" target="_blank">https://www.textyomni.com</a>'
      );
    });
  });

  describe('tweets', () => {
    it('should return the same string if not tags or @mentions', () => {
      const message = 'TextyOmni';
      expect(new MessageFormatter(message).formattedMessage).toEqual(message);
    });

    it('should add links to @mentions', () => {
      const message =
        '@textyomni  @longnonexistenttwitterusername';
      expect(new MessageFormatter(message, true).formattedMessage).toEqual(
        '<a href="http://twitter.com/textyomni" target="_blank" rel="noreferrer nofollow noopener">@textyomni</a>  @longnonexistenttwitterusername'
      );
    });

    it('should add links to #tags', () => {
      const message = '#textyomni';
      expect(new MessageFormatter(message, true).formattedMessage).toEqual(
        '<a href="https://twitter.com/hashtag/textyomni" target="_blank" rel="noreferrer nofollow noopener">#textyomni</a>'
      );
    });
  });
});
