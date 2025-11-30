using eTheater.Services;
using Microsoft.AspNetCore.Mvc;


namespace eTheater.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ChatController : Controller
    {
        private readonly IChatRepository _chatRepository;

        public ChatController(IChatRepository chatRepository)
        {
            _chatRepository = chatRepository;

        }

        [HttpPost]
        public async Task<IActionResult> Post([FromBody] ChatRequest request)
        {
            if (string.IsNullOrWhiteSpace(request.Message))
                return BadRequest(new { error = "Message cannot be empty." });

            var reply = await _chatRepository.GetResponseAsync(request.Message,request.PreviousResponse);

            return Ok(new { reply });

        }
    }

    public class ChatRequest
    {
        public string Message { get; set; } = string.Empty;
        public string PreviousResponse { get; set; } = string.Empty;
    }
}
