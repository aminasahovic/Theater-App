using eTheater.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace eTheater.API.Controllers
{
    [ApiController]
    [Route("api/admin-chat")]
    [Authorize]
    public class AdminChatController : ControllerBase
    {
        private readonly IAdminChatRepository _adminChatRepository;

        public AdminChatController(IAdminChatRepository adminChatRepository)
        {
            _adminChatRepository = adminChatRepository;
        }

        [HttpPost]
        public async Task<IActionResult> Post([FromBody] AdminChatRequest request)
        {
            if (string.IsNullOrWhiteSpace(request.Message))
                return BadRequest(new { error = "Message cannot be empty." });

            var reply = await _adminChatRepository.GetResponseAsync(request.Message, request.PreviousResponse);

            return Ok(new { reply });
        }
    }

    public class AdminChatRequest
    {
        public string Message { get; set; } = string.Empty;
        public string PreviousResponse { get; set; } = string.Empty;
    }
}
