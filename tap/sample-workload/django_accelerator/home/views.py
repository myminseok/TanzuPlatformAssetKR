from django.http import HttpResponse

def homePageView(request):
    response = HttpResponse()
    response.writelines("<h1> Hello</h1>")
    return response
