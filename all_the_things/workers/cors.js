// Template worker at https://developers.cloudflare.com/workers/examples/alter-headers
async function handleRequest(request) {
    // Add request header of access-control-allow-methods to origin.
    request = new Request(request)
    request.headers.set("access-control-allow-methods", "GET,POST,OPTIONS")
  
    let response = await fetch(request)
    // Make the response headers mutable (changeable) by re-constructing the Response
    response = new Response(response.body, response)
    response.headers.set("x-powered-by", "Cloudflare Workers Rock")
    return response
  }
  
  addEventListener("fetch", event => {
    event.respondWith(handleRequest(event.request))
  })
  