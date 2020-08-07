type
  Threads* =ref object
    threads*: seq[Thread]

  Thread* = ref object
    article*:   ThreadArticle
    children*:  seq[Thread]
    num*:       int
    first*:     int
    last*:      int
    endnum*:    int
    body*:      string

  ThreadArticle* = ref object
    num*:         string
    subject*:     string
    from_h*:      string
    date*:        string
    message_id*:  string
    references*:  seq[string]
    bytes*:       string
    lines*:       string
