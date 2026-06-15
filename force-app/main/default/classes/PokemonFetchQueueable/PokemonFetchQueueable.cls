public class PokemonFetchQueueable implements Queueable, Database.AllowsCallouts {
  private String currentEndpoint;

  public PokemonFetchQueueable(String endpoint) {
    this.currentEndpoint = endpoint;
  }

  public void execute(QueueableContext context) {
    PokemonIntegration.PokemonListWrapper listResult = PokemonIntegration.getPokemonList(
      this.currentEndpoint
    );

    if (listResult == null || listResult.results == null) {
      return;
    }

    List<Pokemon__c> pokemonsToInsert = new List<Pokemon__c>();

    for (PokemonIntegration.PokemonItem item : listResult.results) {
      PokemonIntegration.PokemonDetailWrapper detail = PokemonIntegration.getPokemonDetails(
        item.url
      );

      if (detail != null) {
        Pokemon__c poke = new Pokemon__c();
        poke.Name = detail.name;
        poke.Pokemon_Id__c = detail.id;
        poke.Base_Experience__c = detail.base_experience;
        poke.Sprite_URL__c = detail.sprites.front_default;
        poke.url__c = item.url;

        if (detail.types != null && !detail.types.isEmpty()) {
          poke.Primary_Type__c = detail.types[0].type.name;
        }

        pokemonsToInsert.add(poke);
      }
    }

    if (!pokemonsToInsert.isEmpty()) {
      Database.upsert(pokemonsToInsert, Pokemon__c.Fields.Pokemon_Id__c, false);
    }

    if (String.isNotBlank(listResult.next)) {
      System.enqueueJob(new PokemonFetchQueueable(listResult.next));
    }
  }
}
