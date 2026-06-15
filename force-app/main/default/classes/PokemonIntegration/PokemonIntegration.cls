public with sharing class PokemonIntegration {
  public static PokemonListWrapper getPokemonList(String endpoint) {
    Http http = new Http();
    HttpRequest request = new HttpRequest();
    request.setEndpoint(endpoint);
    request.setMethod('GET');
    request.setTimeout(120000);

    HttpResponse response = http.send(request);

    if (response.getStatusCode() == 200) {
      return (PokemonListWrapper) JSON.deserialize(
        response.getBody(),
        PokemonListWrapper.class
      );
    }
    return null;
  }

  public static PokemonDetailWrapper getPokemonDetails(String detailEndpoint) {
    Http http = new Http();
    HttpRequest request = new HttpRequest();
    request.setEndpoint(detailEndpoint);
    request.setMethod('GET');

    HttpResponse response = http.send(request);

    if (response.getStatusCode() == 200) {
      return (PokemonDetailWrapper) JSON.deserialize(
        response.getBody(),
        PokemonDetailWrapper.class
      );
    }
    return null;
  }
  public class PokemonListWrapper {
    public Integer count;
    public String next;
    public List<PokemonItem> results;
  }

  public class PokemonItem {
    public String name;
    public String url;
  }

  public class PokemonDetailWrapper {
    public Integer id;
    public String name;
    public Integer base_experience;
    public List<TypeGroup> types;
    public SpriteGroup sprites;
  }

  public class TypeGroup {
    public TypeDetail type;
  }

  public class TypeDetail {
    public String name;
  }

  public class SpriteGroup {
    public String front_default;
  }
}
