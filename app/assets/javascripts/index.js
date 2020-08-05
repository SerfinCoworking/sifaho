// Define getters into a class
class Page{
  get controller(){
    return $("meta[name=psj]").attr("controller");
  }

  get action(){
    return $("meta[name=psj]").attr("action");
  }
}

const _PAGE = new Page;